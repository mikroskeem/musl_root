#!/bin/sh

set -e

. ./config.sh
. scripts/config_init.sh
. scripts/colors.sh
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
if [ ! -f "${tools_dir}/.finished" ]; then
    status "Building tools"
    . stages/tools/build.sh

    cd "${root_dir}"
    copy_stage

    status "${_cgreen}stage1${_cnormal} built"
fi

if should_build_stage "stage0"; then
    status "Building ${_cgreen}stage0${_cnormal}"
    . stages/stage0/build.sh

    cd "${root_dir}"
    copy_stage || return 1
    stage_built
fi

export PATH="${_oldpath}"

if should_build_stage "stage1"; then
    status "Building ${_cgreen}stage1${_cnormal}"
    . stages/stage1/build.sh

    cd "${root_dir}"
    copy_stage || return 1
    stage_built
fi

exit 0

if should_build_stage "stage2"; then
    status "Building ${_cgreen}stage2${_cnormal}"
    . stages/stage2/build.sh

    cd "${root_dir}"
    copy_stage || return 1
    stage_built
fi
