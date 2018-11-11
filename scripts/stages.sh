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
    echo ">>> Stage '${current_stage}' built"
}

copy_stage () {
    echo ">>> Copying built stage"

    local _xz="xz ${XZ_FLAGS}"
    if [ "${compress_stages}" = "YES" ]; then
        fakeroot tar -C "${target_dir}" -cf - . \
            | ${_xz} -c \
            > "${root_dir}"/stages/"${current_stage}"/finished.tar.xz || return 1
    else
        fakeroot tar -C "${target_dir}" -cf - . \
            > "${root_dir}"/stages/"${current_stage}"/finished.tar || return 1
    fi

    echo ">>> Done"
}

get_stage_archive () {
    local stagename="${1}"

    if [ "${compress_stages}" = "YES" ]; then
        printf "%s" "${stages_dir}/${stagename}/finished.tar.xz"
    else
        echo "%s" "${stages_dir}/${stagename}/finished.tar"
    fi
}

should_build_package () {
    local f="${stages_dir}/${current_stage}/built_packages.txt"

    ! grep -q "${1}" "${f}"
    return "${?}"
}

package_built () {
    local f="${stages_dir}/${current_stage}/built_packages.txt"
    echo "${1}" >> "${f}"
}
