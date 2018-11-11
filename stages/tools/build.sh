#
# Host tools build script
#
current_stage="tools"

build_dir=""
target_dir="$(create_build_tmp)"

# Fetch sources
fetch "${musl_url}"

# Build musl
{
    build_dir="$(create_tmp "musl")"
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
    make install
}
