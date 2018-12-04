#
# Stage-related scripts
#

touch stages/built.txt

should_build_stage () {
    if (printf "%s" "${stages}" | grep -q "${1}") && ! grep -q "${1}" "${root_dir}"/stages/built.txt; then
        return 0
    fi

    return 1
}

stage_built () {
    echo "${current_stage}" >> "${root_dir}"/stages/built.txt
    status "Stage '${_cgreen}${current_stage}${_cnormal}' built"
}

copy_stage () {
    status "Copying built stage"

    _xz="xz ${XZ_FLAGS}"
    if [ "${compress_stages}" = "YES" ]; then
        fakeroot tar -C "${target_dir}" -cf - . \
            | ${_xz} -c \
            > "${root_dir}"/stages/"${current_stage}"/finished.tar.xz || return 1
    else
        fakeroot tar -C "${target_dir}" -cf - . \
            > "${root_dir}"/stages/"${current_stage}"/finished.tar || return 1
    fi

    status "Done"
}

get_stage_archive () {
    stagename="${1}"

    if [ "${compress_stages}" = "YES" ]; then
        printf "%s" "${root_dir}/stages/${stagename}/finished.tar.xz"
    else
        printf "%s" "${root_dir}/stages/${stagename}/finished.tar"
    fi
}

_logfifo=""
_teepid=""

prepare_logging () {
    stagename="${1}"
    fname="${2}"

    if [ -z "${fname}" ]; then
        fname="$(create_tmp "${stagename}-buildlog")/build.log"
    fi

    # Create logging fifo if verbosse logging is wanted
    if [ "${verbose_logging}" = "ON" ]; then
        if ! [ -z "${_teepid}" ] && (kill -0 "${_teepid}" 2>/dev/null); then
            kill -2 "${_teepid}"
        fi

        if ! [ -z "${_logfifo}" ]; then
            rm "${_logfifo}"
        fi

        _logfifo="$(dirname "${fname}")/verboselog.fifo"
        mkfifo "${_logfifo}"
    fi

    touch "${fname}"
    inform "Stage '${stagename}' build log file is at: '${fname}'"

    if [ "${verbose_logging}" = "ON" ]; then
        sh -c "tail -f '${_logfifo}' | tee '${fname}' >&2" >&2 &
        _teepid="${!}"
        inform "Debug pipe started at PID ${_teepid}"

        printf "%s" "${_logfifo}"
    else
        printf "%s" "${fname}"
    fi
}
