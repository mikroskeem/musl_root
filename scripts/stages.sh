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
    state "Stage '${_cgreen}${current_stage}${_cnormal}' built"
}

copy_stage () {
    state "Copying built stage"

    _xz="xz ${XZ_FLAGS}"
    if [ "${compress_stages}" = "YES" ]; then
        fakeroot tar -C "${target_dir}" -cf - . \
            | ${_xz} -c \
            > "${root_dir}"/stages/"${current_stage}"/finished.tar.xz || return 1
    else
        fakeroot tar -C "${target_dir}" -cf - . \
            > "${root_dir}"/stages/"${current_stage}"/finished.tar || return 1
    fi

    state "Done"
}

get_stage_archive () {
    stagename="${1}"

    if [ "${compress_stages}" = "YES" ]; then
        printf "%s" "${root_dir}/stages/${stagename}/finished.tar.xz"
    else
        printf "%s" "${root_dir}/stages/${stagename}/finished.tar"
    fi
}
