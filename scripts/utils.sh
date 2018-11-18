#
# Various utils
#

# creates stage build directory
create_build_tmp () {
    mktemp -d "${tmpbuilds}.${current_stage}.XXXXXX"
}

# directory (middle) suffix
create_tmp () {
    if [ "${use_tmp}" = "YES" ] && [ ! "${2}" = "DISK" ]; then
        mktemp -d "${TMPDIR:-/tmp}/muslroot-${1}.XXXXXX"
    else
        mktemp -d "${root_dir}/tmp/muslroot-${1}.XXXXXX"
    fi
}

# url
_extract_name () {
    basename "$(printf '%s' "${1}" | sed 's/\(.*\):http.*/\1/')"
}

# url
_extract_url () {
    printf '%s' "${1}" | sed 's/.*:\(http.*\)/\1/'
}

# source
_dl_tool=""

# shellcheck disable=SC2016,SC2034
fetch () {
    name="$(_extract_name "${1}")"
    url="$(_extract_url "${1}")"
    file="${sources}/${name}"
    if [ -f "${file}" ]; then
        return 0
    fi

    if [ -z "${_dl_tool}" ]; then
        if [ ! -z "$(command -v curl)" ]; then
            _dl_tool='curl -L -o ${file} --connect-timeout 10 --retry 5 --retry-delay 2 --retry-max-time 15 ${url}'
        elif [ ! -z "$(command -v aria2c)" ]; then
            _dl_tool='aria2 -o ${file} ${url}'
        elif [ ! -z "$(command -v wget)" ]; then
            _dl_tool='wget -O ${file} ${url}'
        fi
    fi

    inform "Downloading '${name}'"
    eval "${_dl_tool}"
    return "${?}"
}

# target dir, package
unpack () {
    name="$(_extract_name "${2}")"
    file="${sources}/${name}"

    inform "Unpacking '${name}'"
    tar -C "${1}" -xf "${file}" || return "${?}"
}

has_quirk () {
    printf "%s" "${host_quirks}" | grep -q "${1}"
    return "${?}"
}

apply_patches () {
    name="$(_extract_name "${1}")"
    quirks=""
    should_apply=""
    name="${name%%.tar*}"

    if [ -d "${patches}/${name}" ]; then
        inform "Applying patches for '${name}'"
        find "${patches}/${name}" -mindepth 1 -maxdepth 1 -name "*.patch" | while read -r _p; do
            # Check if patch should be applied
            quirks="$(grep '^!quirk: ' "${_p}" | sed '/^!quirk: /{s///g}')"
            should_apply="YES"

            for quirk in ${quirks}; do
                if ! has_quirk "${quirk}"; then
                    should_apply=""
                    break
                fi
            done

            if [ "${should_apply}" = "YES" ]; then
                inform "Applying patch: $(basename "${_p}")"
                patch -p1 < "${_p}" || return "${?}"
            fi
        done
    fi
}

mkdirp () {
   mkdir "${1}" || return 1
   cd "${1}" || return 1
}
