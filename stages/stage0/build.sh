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
fetch "${linux_kernel_url}"

fetch "${binutils_url}"
fetch "${gcc_url}"
fetch "${gmp_url}"
fetch "${mpfr_url}"
fetch "${mpc_url}"

# Define cross compiler env var
cc_target="$(uname -m)-unknown-linux-musl"

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

    make CROSS_COMPILE="${cc_target}-" defconfig

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

    make CROSS_COMPILE="${cc_target}-"

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

    CFLAGS="-static" ../configure \
        --host="${cc_target}" \
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
    CFLAGS="-static" ../configure \
        --host="${cc_target}" \
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

    CFLAGS="-static" ../configure \
        --host="${cc_target}" \
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

    CFLAGS="-static" ../configure \
        --host="${cc_target}" \
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

    make CC="${cc_target}-gcc -static"
    cp unshare "${target_dir}/tools/bin"
fi

# Extract kernel headers
{
    build_dir="$(create_tmp "kernel-headers")"
    cd "${build_dir}"


    unpack "${build_dir}" "${linux_kernel_url}"
    cd linux-"${linux_kernel_version}"
    apply_patches "${linux_kernel_url}"

    make mrproper
    make ARCH="$(uname -m)" \
        INSTALL_HDR_PATH="${target_dir}/usr" \
        headers_install
}

# Build musl
{
    build_dir="$(create_tmp "target-musl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${musl_url}"
    apply_patches "${musl_url}"
    cd musl-"${musl_version}"

    mkdirp build
    ../configure \
        --host="${cc_target}" \
        --prefix="/usr" \
        --syslibdir="/usr/lib" \
        --disable-wrapper

    make
    make DESTDIR="${target_dir}" install

    # Install ldd symlink
    ln -s "/usr/lib/ld-musl-$(uname -m).so.1" "${target_dir}/usr/bin/ldd"
}

# Build target gcc
{
    build_dir="$(create_tmp "target-gcc" "DISK")"
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

    # Build binutils
    cd "${build_dir}/binutils-${binutils_version}"
    mkdirp build
    ../configure \
        --host="${cc_target}" \
        --target="${cc_target}" \
        --prefix="/tools" \
        --disable-nls \
        --disable-multilib \
        --disable-werror \
        --disable-rpath \
        --enable-shared

    make configure-host
    make
    make DESTDIR="${target_dir}" install

    # XXX: apparently this doesn't exist when host == target?
    # Check for ${cc_target}-as
    #[ ! -f "${target_dir}/tools/bin/${cc_target}-as" ] && {
    #    echo ">>> binutils did not build properly - '${cc_target}-as' not found"
    #    exit 1
    #}

    # Check for as
    [ ! -f "${target_dir}/tools/bin/as" ] && {
        echo ">>> binutils did not build properly - 'as' not found"
        exit 1
    }


    # Build gcc
    cd "${build_dir}/gcc-${gcc_version}"

    # Disable fixincludes and don't use lib64
    sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in
    sed -i '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64

    mkdirp build
    ../configure \
        --host="${cc_target}" \
        --target="${cc_target}" \
        --prefix="/tools" \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --disable-libsanitizer \
        --enable-default-pie \
        --enable-default-ssp \
        --enable-languages=c,c++ \
        --enable-tls

    make all-gcc all-target-libgcc
    make DESTDIR="${target_dir}" install-gcc install-target-libgcc

    # Check if GCC built properly
    [ ! -f "${target_dir}/tools/bin/${cc_target}-gcc" ] && {
        echo ">>> gcc did not build properly - '${cc_target}-gcc' not found"
        exit 1
    }

    # Symlink cc to gcc
    ln -s gcc "${target_dir}/tools/bin/cc"
}
