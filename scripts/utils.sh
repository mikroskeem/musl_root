#
# Various utils
#

# creates stage build directory
create_build_tmp () {
    mktemp -d "${tmpbuilds}.${current_stage}.XXXXX"
}

# directory (middle) suffix
create_tmp () {
    if [ "${use_tmp}" = "YES" ]; then
        mktemp -d "${TMPDIR:-/tmp}/muslroot-${1}.XXXXX"
    else
        mktemp -d "tmp/muslroot-${1}.XXXXX"
    fi
}

# source
_dl_tool=""
fetch () {
    local name="$(basename "${1}")"
    local file="${sources}/${name}"
    if [ -f "${file}" ]; then
        return 0
    fi

    if [ -z "${_dl_tool}" ]; then
        if [ ! -z "$(command -v curl)" ]; then
            _dl_tool='curl -L -o ${file} ${1}'
        elif [ ! -z "$(command -v aria2c)" ]; then
            _dl_tool='aria2 -o ${file} ${1}'
        elif [ ! -z "$(command -v wget)" ]; then
            _dl_tool='wget -O ${file} ${1}'
        fi
    fi

    echo ">>> Downloading '${name}'"
    eval "${_dl_tool}"
    return "${?}"
}

# target dir, package
unpack () {
    local name="$(basename "${2}")"
    local file="${sources}/${name}"

    echo ">>> Unpacking '${name}'"
    tar -C "${1}" -xf "${file}" || return "${?}"
}

apply_patches () {
    local name="$(basename "${1}")"
    local quirks=""
    local _should_apply=""
    name="${name%%.tar*}"

    if [ -d "${patches}/${name}" ]; then
        echo ">>> Applying patches for '${name}'"
        find "${patches}/${name}" -mindepth 1 -maxdepth 1 -name "*.patch" | while read -r _p; do
            # Check if patch should be applied
            quirks="$((grep '^!quirk: ' "${_p}" | sed '/^!quirk: /{s///g}') || true)"
            _should_apply="YES"

            for quirk in ${quirks}; do
                if ! (printf "%s" "${host_quirks}" | grep -q "${quirk}"); then
                    _should_apply=""
                    break
                fi
            done

            if [ "${_should_apply}" = "YES" ]; then
                echo ">>> Applying patch: $(basename "${_p}")"
                patch -p1 < "${_p}" || return "${?}"
            fi
        done
    fi
}

mkdirp () {
   mkdir "${1}" || return 1
   cd "${1}" || return 1
}
