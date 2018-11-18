#
# CLI arguments parser
#

handle_argument () {
    case "${1}" in
        "help"|"-h"|"--help")
            cat <<EOF
musl_root - Yet another Musl-based lightweight container or distribution bootstrapper

Usage:
    ${_cred}${_cbold}help, -h, --help${_cnormal}
        Show this help text and exits

    ${_cred}${_cbold}clean${_cnormal}
        Cleans up '${_cblue}${root_dir}/tmp${_cnormal}' and built stage tarballs

    ${_cred}${_cbold}exit${_cnormal}
        Exits script immediately after processing command line arguments.
        Note that this ${_cred}*must*${_cnormal} be the last argument, as arguments are processed
        in order.
EOF
            exit 0
            ;;
        "clean")
            rm "${root_dir}/stages/built.txt" >/dev/null || true

            inform "Removing built stage tarballs"
            find "${root_dir}/stages" -type f -name "finished.tar*" -print -delete || true

            inform "Removing '${root_dir}/tmp'"
            rm -rf "${root_dir}/tmp" >/dev/null || true
            mkdir -p "${root_dir}/tmp"
            ;;
        "exit")
            exit 0
            ;;
        *)
            warning "Unknown argument: '${1}'"
            exit 1
            ;;
    esac
}

while [ ! -z "${1}" ]; do
    handle_argument "${1}"
    shift
done
