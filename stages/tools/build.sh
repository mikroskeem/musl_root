#
# Host tools build script
#
current_stage="tools"

build_dir=""
target_dir="${root_dir}/tools"

# Fetch sources
fetch "${libtool_url}"
fetch "${musl_url}"
fetch "${sabotage_kernel_headers_url}"
fetch "${m4_url}"

# Build musl
if has_quirk "build_musl_gcc_wrapper"; then
    build_dir="$(create_tmp "host-musl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${musl_url}"
    cd musl-"${musl_version}"
    apply_patches "${musl_url}"

    mkdirp build
    ../configure \
        --prefix="${target_dir}" \
        --syslibdir="${target_dir}/lib" \
        --enable-wrapper=gcc

    make
    make install
fi

# Build kernel headers
if has_quirk "no_kernel_headers" || has_quirk "build_musl_gcc_wrapper"; then
    build_dir="$(create_tmp "host-kernel-headers")"
    cd "${build_dir}"

    unpack "${build_dir}" "${sabotage_kernel_headers_url}"
    cd kernel-headers-"${sabotage_kernel_headers_version}"
    apply_patches "${sabotage_kernel_headers_url}"

    make ARCH="$(uname -m)" prefix="${target_dir}" install
fi

# Build m4
if has_quirk "build_own_m4"; then
    build_dir="$(create_tmp "host-m4")"
    cd "${build_dir}"

    unpack "${build_dir}" "${m4_url}"
    cd m4-"${m4_version}"
    apply_patches "${m4_url}"

    mkdirp build
    ../configure \
        --prefix="${target_dir}"

    make
    make install
fi

# Build libtool
if has_quirk "build_own_libtool"; then
    build_dir="$(create_tmp "host-libtool")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libtool_url}"
    cd libtool-"${libtool_version}"
    apply_patches "${libtool_url}"

    mkdirp build
    ../configure \
        --prefix="${target_dir}"

    make
    make install
fi

# Mark stage finished
{
    date +%s > "${target_dir}/.finished"
}
