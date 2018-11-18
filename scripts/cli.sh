#
# CLI arguments parser
#

handle_argument () {
    case "${1}" in
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
