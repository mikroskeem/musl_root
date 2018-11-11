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

echo ">>> Checking available host tools..."

check_command "musl-gcc" s || (
    echo "musl-gcc is required for building right now"
    exit 1
);

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
check_command "libtool" || exit 1
check_command "fakeroot" || exit 1

check_command "xz" || {
    echo "Disabling compression, xz not found in PATH=${PATH}"
    compress_stages=NO
}
