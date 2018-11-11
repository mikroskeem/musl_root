#
# Stage 0 build script
#
current_stage="stage0"

build_dir=""
target_dir="$(create_build_tmp)"

# Fetch sources
fetch "${busybox_url}"
fetch "${musl_url}"
fetch "${make_url}"
fetch "${libtool_url}"
fetch "${pkg_config_url}"

# Build musl
{
    build_dir="$(create_tmp "musl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${musl_url}"
    cd musl-"${musl_version}"
    apply_patches "${musl_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --syslibdir=/usr/lib

    make
    make DESTDIR="${target_dir}" install
}

# Build busybox
{
    build_dir="$(create_tmp "busybox")"
    cd "${build_dir}"

    unpack "${build_dir}" "${busybox_url}"
    cd busybox-"${busybox_version}"
    apply_patches "${busybox_url}"

    make defconfig

    # Ehh...
    sed -i '/^CONFIG_AR=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_DPKG.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_I2C.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_MKFS.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_FSCK.*=/{s/=y/=n/g}' .config

    make

    # Install busybox by hand
    mkdir -p "${target_dir}"/tools/bin
    cp busybox "${target_dir}"/tools/bin

    for applet in $(busybox --list); do
        ln -s busybox "${target_dir}"/usr/bin/"${applet}" || true
    done
}

# Build static make
{
    build_dir="$(create_tmp "make")"
    cd "${build_dir}"

    unpack "${build_dir}" "${make_url}"
    cd make-"${make_version}"
    apply_patches "${make_url}"

    mkdirp build

    CC="${CC:-cc} -static" ../configure \
        --prefix=/tools \
        --without-guile

    make
    make DESTDIR="${target_dir}" install
}

# Build static libtool
{
    build_dir="$(create_tmp "libtool")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libtool_url}"
    cd libtool-"${libtool_version}"
    apply_patches "${libtool_url}"

    mkdirp build

    CC="${CC:-cc} -static" ../configure \
        --prefix=/tools

    make
    make DESTDIR="${target_dir}" install
}

# Build static pkg-config
{
    build_dir="$(create_tmp "pkg-config")"
    cd "${build_dir}"

    unpack "${build_dir}" "${pkg_config_url}"
    cd pkg-config-"${pkg_config_version}"
    apply_patches "${pkg_config_url}"

    mkdirp build

    CC="${CC:-cc} -static" ../configure \
        --prefix=/tools \
        --with-internal-glib

    make
    make DESTDIR="${target_dir}" install
}
