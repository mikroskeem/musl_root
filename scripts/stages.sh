#
# Stage-related scripts
#

touch stages/built.txt

should_build_stage () {
    if (echo -n "${stages}" | grep -q "${1}") && ! grep -q "${1}" stages/built.txt; then
        return 0
    fi

    return 1
}

stage_built () {
    echo "${1}" >> stages/built.txt
}
