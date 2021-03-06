#
# Checks host system tools
#

check_command () {
    if [ -z "$(command -v "${1}")" ]; then
        [ "${2}" = "s" ] || echo "Command '${1}' not found in PATH=${PATH}"
        return 1
    fi

    return 0
}

_run_native () {
    required="${1}"
    _check="$(mktemp /tmp/muslroot-hosttest.XXXXXX)"
    _check_log="${_check}.log"
    _out=""

    set +e

    mv "${_check}" "${_check}.c"
    _check="${_check}.c"
    cat > "${_check}"
    if "${CC:-cc}" "${_check}" -o "${_check}.b" > "${_check_log}" 2>&1; then
        _out="$("${_check}.b")"
        rm "${_check}.b"
    else
        if [ "${required}" = "YES" ]; then
            _out="fail:${_check_log}"
        fi
    fi

    rm "${_check}"

    set -e

    printf "%s" "${_out}"
}

host_quirks=""
tools_available="YES"

inform "Checking available host tools..."

check_command "basename" || { tools_available=NO; }
check_command "grep" || { tools_available=NO; }
check_command "sed" || { tools_available=NO; }
check_command "patch" || { tools_available=NO; }
check_command "tar" || { tools_available=NO; }

check_command "curl" s || \
    check_command "aria2" s || \
    check_command "wget" s || \
    (check_command "busybox" && busybox --list | grep -q "^wget") || \
    { echo "Neither curl, aria2 or wget or busybox (or its wget applet isn't enabled) was found in PATH=${PATH}"; tools_available=NO; }

check_command "${CC:-cc}" || { tools_available=NO; }
check_command "find" || { tools_available=NO; }
check_command "make" || { tools_available=NO; }
check_command "pkg-config" || { tools_available=NO; }
check_command "fakeroot" || { tools_available=NO; }

if ! check_command "bwrap" s; then
    host_quirks="${host_quirks}unisolated_stage_build ";
    check_command "chroot" || { tools_available=NO; }
else
    # Simple test
    _bwrap_works="$(bwrap --unshare-all --share-net --die-with-parent \
        --ro-bind / / \
        /bin/sh -c "printf '%s' 'YES'" \
        2>/dev/null || true
    )"

    if [ ! "${_bwrap_works}" = "YES" ]; then
        warning "bubblewrap didn't seem to work, falling back to chroot"
        host_quirks="${host_quirks}unisolated_stage_build ";
        check_command "chroot" || { tools_available=NO; }
    fi
fi

check_command "m4" s || {
    warning "Building own M4 as host does not provide it"
    host_quirks="${host_quirks}build_own_m4 "
}

check_command "libtool" s || {
    warning "Building own libtool as host does not provide it"
    host_quirks="${host_quirks}build_own_libtool "
}

check_command "xz" s || {
    if [ "${compress_stages}" = "YES" ]; then
        warning "Disabling compression, xz not found in PATH=${PATH}"
        compress_stages=NO
    fi
}

inform "Checking available host libraries..."
# None right now

if [ ! "${tools_available}" = "YES" ]; then
    error "Please install required tools listed above and run this script again"
    exit 1
fi

if [ ! -z "${host_quirks}" ]; then
    note ">>> Host quirks: ${host_quirks}"
fi

unset tools_available
