#!/bin/sh

set -e

. ./config.sh
. scripts/config_init.sh
. scripts/prereqs.sh
. scripts/sources.sh
. scripts/cli.sh
. scripts/stages.sh
. scripts/utils.sh

root_dir="$(pwd)"
current_stage=""

if should_build_stage "stage0" "${stages}"; then
    echo ">>> Building stage0"
    . stages/stage0/build.sh

    cd "${root_dir}"
    stage_built "stage0"

    echo ">>> Copying built stage"
    fakeroot tar -C "${target_dir}" -cf - . \
        > stages/stage0/finished.tar

    echo ">>> stage0 built"
fi

exit 0

if should_build_stage "stage1" "${stages}"; then
    echo ">>> Building stage1"
    . stages/stage1/build.sh

    cd "${root_dir}"
    stage_built "stage1"

    echo ">>> Copying built stage"
    fakeroot tar -C "${target_dir}" -cf - . \
        > stages/stage1/finished.tar

    echo ">>> stage1 built"
fi

if should_build_stage "stage2" "${stages}"; then
    echo ">>> Building stage2"
    . stages/stage2/build.sh
    stage_built "stage2"

    echo ">>> Copying built stage"
    fakeroot tar -C "${target_dir}" -cf - . \
        > stages/stage2/finished.tar

    echo ">>> stage2 built"
fi
