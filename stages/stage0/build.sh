#
# Stage 0 build script
#
current_stage="stage0"

build_dir=""
target_dir="$(create_build_tmp)"

_ctools_dir=""
_target=""

# Fetch sources
fetch "${busybox_url}"
fetch "${musl_url}"
fetch "${make_url}"
fetch "${libtool_url}"
fetch "${pkg_config_url}"
fetch "${unshare_lite_url}"
fetch "${sabotage_kernel_headers_url}"

fetch "${binutils_url}"
fetch "${gcc_url}"
fetch "${gmp_url}"
fetch "${mpfr_url}"
fetch "${mpc_url}"

# Define cross compiler env var
CROSS_COMPILE="${root_dir}/tools/cross/bin/$(uname -m)-linux-musl-"

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

exit 1

# Build target gcc
{
    build_dir="$(create_tmp "target-gcc")"
    _gcc_dir="${build_dir}/gcc-${gcc_version}"
    cd "${build_dir}"

    unpack "${build_dir}" "${binutils_url}"
    unpack "${build_dir}" "${gcc_url}"
    unpack "${build_dir}" "${gmp_url}"
    unpack "${build_dir}" "${mpfr_url}"
    unpack "${build_dir}" "${mpc_url}"

    cd "${build_dir}/binutils-${binutils_version}" && apply_patches "${binutils_url}"
    cd "${build_dir}/gcc-${gcc_version}" && apply_patches "${gcc_url}"
    cd "${build_dir}/gmp-${gmp_version}" && apply_patches "${gmp_url}"
    cd "${build_dir}/mpfr-${mpfr_version}" && apply_patches "${mpfr_url}"
    cd "${build_dir}/mpc-${mpc_version}" && apply_patches "${mpc_url}"

    # Symlink GMP, MPFR and MPC to GCC source dir
    ln -s ../gmp-"${gmp_version}" "${_gcc_dir}/gmp"
    ln -s ../mpfr-"${mpfr_version}" "${_gcc_dir}/mpfr"
    ln -s ../mpc-"${mpc_version}" "${_gcc_dir}/mpc"

    _target="$(uname -m)-linux-musl"

    # Build binutils
    cd "${build_dir}/binutils-${binutils_version}"
    mkdirp build
    CC="${_cc}" ../configure \
        --prefix="${build_dir}/tools/cross" \
        --target="${_target}" \
        --disable-nls \
        --disable-multilib \
        --disable-werror \
        --disable-rpath \
        --enable-shared \
        --with-sysroot="${build_dir}"

    make configure-host
    make
    make install

    # Check for ${_target}-as
    __oldpath="${PATH}"
    export PATH="${build_dir}/tools/cross/bin:${PATH}"

    [ -z "$(command -v "${_target}-as")" ] && {
        echo ">>> binutils did not build properly"
        exit 1
    }

    # Build gcc
    cd "${build_dir}/gcc-${gcc_version}"
    mkdirp build
    CC="${_cc}" ../configure \
        --prefix="${build_dir}/tools/cross" \
        --target="${_target}" \
        --disable-decimal-float \
        --disable-libgomp \
        --disable-libmudflap \
        --disable-libssp \
        --disable-multilib \
        --disable-nls \
        --disable-shared \
        --disable-threads \
        --disable-werror \
        --enable-languages=c \
        --enable-tls \
        --with-newlib \
        --with-sysroot="${build_dir}" \
        --without-headers

    make all-gcc all-target-libgcc
    make install-gcc install-target-libgcc

    # Check if GCC built properly
    [ -z "$(command -v "${_target}-gcc")" ] && {
        echo ">>> gcc did not build properly - '${_target}-gcc' not found"
        exit 1
    }

    export PATH="${__oldpath}"
}

# Build target musl

unset _cc
