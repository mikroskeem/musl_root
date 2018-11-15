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
fetch "${unshare_lite_url}"
fetch "${sabotage_kernel_headers_url}"

# Use musl-gcc if needed
_cc="${CC:-cc}"
if has_quirk "build_musl_gcc_wrapper"; then
    _cc="${tools_dir}/bin/musl-gcc"
fi

if has_quirk "no_kernel_headers"; then
    _cc="${_cc} -isystem \"${tools_dir}/include\""
fi

# Set up base filesystem
{
    install -d "${target_dir}"/dev
    install -d "${target_dir}"/proc
    install -d "${target_dir}"/sys

    install -d "${target_dir}"/etc

    install -d "${target_dir}"/usr
    install -d "${target_dir}"/usr/bin
    install -d "${target_dir}"/usr/sbin
    install -d "${target_dir}"/usr/lib

    ln -s usr/bin "${target_dir}"/bin
    ln -s usr/bin "${target_dir}"/sbin
    ln -s usr/bin "${target_dir}"/usr/sbin
    ln -s usr/lib "${target_dir}"/lib

    # Symlink busybox sh as default shell
    ln -s /tools/bin/busybox "${target_dir}"/usr/bin/sh
}

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

    make CC="${_cc}" defconfig

    sed -i '/CONFIG_STATIC/{s/.*/CONFIG_STATIC=y/}' .config

    # Ehh...
    sed -i '/^CONFIG_AR=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_DPKG.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_FSCK.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_I2C.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_MK.*FS.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_NAND.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_SV.*=/{s/=y/=n/g}' .config
    sed -i '/^CONFIG_UBI.*=/{s/=y/=n/g}' .config

    make CC="${_cc}"

    # Install busybox by hand
    mkdir -p "${target_dir}"/tools/bin
    cp busybox "${target_dir}"/tools/bin

    for applet in $(./busybox --list); do
        ln -s busybox "${target_dir}"/tools/bin/"${applet}" || true
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

    CC="${_cc} -static" ../configure \
        --prefix=/tools \
        --without-guile

    make
    make DESTDIR="${target_dir}" install
}

# Build static m4
{
    build_dir="$(create_tmp "m4")"
    cd "${build_dir}"

    unpack "${build_dir}" "${m4_url}"
    cd m4-"${m4_version}"
    apply_patches "${m4_url}"

    mkdirp build
    CC="${_cc} -static" ../configure \
        --prefix=/tools

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

    CC="${_cc} -static" ../configure \
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

    CC="${_cc} -static" ../configure \
        --prefix=/tools \
        --with-internal-glib

    make
    make DESTDIR="${target_dir}" install
}

# Build unshare-lite
if has_quirk "unisolated_stage_build"; then
    build_dir="$(create_tmp "unshare-lite")"
    cd "${build_dir}"

    unpack "${build_dir}" "${unshare_lite_url}"
    cd unshare-lite-"${unshare_lite_version}"
    apply_patches "${unshare_lite_url}"

    make CC="${_cc} -static"
    cp unshare "${target_dir}/tools/bin"
fi

# Build kernel headers
{
    build_dir="$(create_tmp "kernel-headers")"
    cd "${build_dir}"

    unpack "${build_dir}" "${sabotage_kernel_headers_url}"
    cd kernel-headers-"${sabotage_kernel_headers_version}"
    apply_patches "${sabotage_kernel_headers_url}"

    make ARCH="$(uname -m)" prefix="/usr" DESTDIR="${target_dir}" install
}

unset _cc
