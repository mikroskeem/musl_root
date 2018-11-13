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

echo ">>> Checking available host tools..."

check_command "basename"
check_command "grep"
check_command "sed"
check_command "patch"
check_command "tar"

check_command "curl" s || \
    check_command "aria2" s || \
    check_command "wget" s || \
    (check_command "busybox" && busybox --list | grep -q "^wget") || \
    (echo "Neither curl, aria2 or wget or busybox (or its wget applet isn't enabled) was found in PATH=${PATH}"; exit 1)

check_command "${CC:-cc}" || exit 1
check_command "find" || exit 1
check_command "make" || exit 1
check_command "pkg-config" || exit 1
check_command "fakeroot" || exit 1
check_command "bwrap" || exit 1

check_command "m4" s || {
    echo ">>> Building own M4 as host does not provide it"
    host_quirks="${host_quirks}build_own_m4 "
}

check_command "libtool" s || {
    echo ">>> Building own libtool as host does not provide it"
    host_quirks="${host_quirks}build_own_libtool "
}

check_command "xz" s || {
    if [ "${compress_stages}" = "YES" ]; then
        echo "Disabling compression, xz not found in PATH=${PATH}"
        compress_stages=NO
    fi
}

echo ">>> Checking available host libraries..."

# Check for glibc version
{
    _glibc_version="$(
_run_native <<- EOF
    #include <stdio.h>
    #include <gnu/libc-version.h>
    int main(void){puts(gnu_get_libc_version());return 0;}
EOF
)"
    if [ ! -z "${_glibc_version}" ]; then
        if [ "$(printf "%s" "${_glibc_version}" | sed 's/\.//')" -ge 228 ]; then
            echo ">>> glibc version: ${_glibc_version}, enabling GNULib and glibc quirk patch"
            host_quirks="${host_quirks}too_new_glibc "
        fi

        host_quirks="${host_quirks}build_musl_gcc_wrapper "
    fi
}

# Check for Linux kernel headers presence
{
    _headers_present="$(
_run_native <<- EOF
    #include <stdio.h>
    #include <linux/version.h>
    int main(void){puts("YES");return 0;}
EOF
)"

    if [ ! "${_headers_present}" = "YES" ]; then
        host_quirks="${host_quirks}no_kernel_headers "
    fi
}

if [ ! -z "${host_quirks}" ]; then
    echo ">>> Host quirks: ${host_quirks}"
fi
