#
# CLI arguments parser
#

handle_argument () {
    case "${1}" in
        "clean")
            echo ">>> Removing built stage tarballs"
            find "${root_dir}/stages" -type f -name "finished.tar*" -print -delete || true

            echo ">>> Removing '${root_dir}/tmp'"
            rm -rf "${root_dir}/tmp"
            ;;
        "exit")
            exit 0
            ;;
        *)
            echo ">>> Unknown argument: '${1}'"
            exit 1
            ;;
    esac
}

while [ ! -z "${1}" ]; do
    handle_argument "${1}"
    shift
done
