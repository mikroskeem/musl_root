#
# Host tools build script
#
current_stage="tools"

build_dir=""
target_dir="$(create_build_tmp)"

# Fetch sources
fetch "${musl_url}"
fetch "${sabotage_kernel_headers_url}"
fetch "${m4_url}"

# Build musl
{
    build_dir="$(create_tmp "host-musl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${musl_url}"
    cd musl-"${musl_version}"
    apply_patches "${musl_url}"

    mkdirp build
    ../configure \
        --prefix="${root_dir}/tools" \
        --syslibdir="${root_dir}/tools/lib" \
        --enable-wrapper=gcc

    make
    make DESTDIR="${target_dir}" install
}

# Build kernel headers
{
    build_dir="$(create_tmp "host-kernel-headers")"
    cd "${build_dir}"

    unpack "${build_dir}" "${sabotage_kernel_headers_url}"
    cd kernel-headers-"${sabotage_kernel_headers_version}"
    apply_patches "${sabotage_kernel_headers_url}"

    make ARCH="$(uname -m)" prefix="${root_dir}/tools" DESTDIR="${target_dir}" install
}

# Build m4
if (printf "%s" "${host_quirks}" | grep -q "build_own_m4"); then
    build_dir="$(create_tmp "host-m4")"
    cd "${build_dir}"

    unpack "${build_dir}" "${m4_url}"
    cd m4-"${m4_version}"
    apply_patches "${m4_url}"

    mkdirp build
    ../configure \
        --prefix="${root_dir}/tools"

    make
    make DESTDIR="${target_dir}" install
fi
