#!/bin/sh

set -e

. ./config.sh
. scripts/config_init.sh
. scripts/prereqs.sh
. scripts/sources.sh
. scripts/stages.sh
. scripts/utils.sh

root_dir="$(pwd)"
tools_dir="${root_dir}/tools"
current_stage=""

. scripts/cli.sh

_oldpath="${PATH}"
export PATH="${tools_dir}/bin:${PATH}"

# Build tools if necessary
if [ ! -d "${tools_dir}/.finished" ]; then
    echo ">>> Building tools"
    . stages/tools/build.sh

    cd "${root_dir}"
    copy_stage

    echo ">>> tools built"
fi

if should_build_stage "stage0"; then
    echo ">>> Building stage0"
    . stages/stage0/build.sh

    cd "${root_dir}"
    copy_stage || return 1
    stage_built
fi

exit 0
export PATH="${_oldpath}"

if should_build_stage "stage1"; then
    echo ">>> Building stage1"
    . stages/stage1/build.sh

    cd "${root_dir}"
    copy_stage || return 1
    stage_built
fi

if should_build_stage "stage2"; then
    echo ">>> Building stage2"
    . stages/stage2/build.sh

    cd "${root_dir}"
    copy_stage || return 1
    stage_built
fi
