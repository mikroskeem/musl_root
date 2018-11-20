#!/bin/bash

_basever="${1}"
_patchlevel="${2}"

# https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/bash#n27
if [[ $((10#${_patchlevel})) -gt 0 ]]; then
    for (( _p=1; _p<=$((10#${_patchlevel})); _p++ )); do
        url="https://ftp.gnu.org/gnu/bash/bash-$_basever-patches/bash${_basever//.}-$(printf "%03d" $_p)"
        name="$(basename "${url}").diff"

        if [ ! -f "${name}" ]; then
            echo ">>> Downloading '${name}'"
            curl -o "${name}" "${url}"
        fi
    done
fi
