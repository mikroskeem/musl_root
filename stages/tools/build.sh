#
# Host tools build script
#
current_stage="tools"

build_dir=""
target_dir="${root_dir}/tools"

cc_target="$(uname -m)-unknown-linux-musl"

# Fetch sources
fetch "${libtool_url}"
fetch "${musl_url}"
fetch "${linux_kernel_url}"
fetch "${m4_url}"

fetch "${binutils_url}"
fetch "${gcc_url}"
fetch "${gmp_url}"
fetch "${mpfr_url}"
fetch "${mpc_url}"

# Build cross compiler
{
    build_dir="$(create_tmp "cross-gcc" "DISK")"
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

    # Configure without optimization and debug info,
    # reduces overall build time
    CFLAGS="-O0 -g0" \
    CXXFLAGS="-O0 -g0" \
    ../configure \
        --prefix="${target_dir}" \
        --target="${cc_target}" \
        --disable-install-libbfd \
        --disable-nls \
        --disable-multilib \
        --disable-werror \
        --disable-rpath \
        --enable-shared \
        --with-lib-path="${target_dir}" \
        --with-sysroot="${target_dir}"

    make configure-host
    make
    make install

    # Check for ${_target}-as
    [ -z "$(command -v "${cc_target}-as")" ] && {
        echo ">>> binutils did not build properly"
        exit 1
    }

    # Build gcc
    cd "${build_dir}/gcc-${gcc_version}"

    # Disable fixincludes and don't use lib64
    sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in
    sed -i '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64

    mkdirp build

    CFLAGS="-O0 -g0" \
    CXXFLAGS="-O0 -g0" \
    ../configure \
        --prefix="${target_dir}" \
        --target="${cc_target}" \
        --disable-decimal-float \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libmudflap \
        --disable-libmpx \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libstdcxx \
        --disable-libvpv \
        --disable-multilib \
        --disable-nls \
        --disable-shared \
        --disable-threads \
        --disable-werror \
        --enable-languages=c \
        --enable-tls \
        --with-local-prefix="${target_dir}/include" \
        --with-newlib \
        --with-sysroot="${target_dir}" \
        --without-headers

    make
    make install

    # Check if GCC built properly
    [ -z "$(command -v "${cc_target}-gcc")" ] && {
        echo ">>> gcc did not build properly - '${_target}-gcc' not found"
        exit 1
    }

    # Create limits.h
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        "$(dirname "$("${cc_target}-gcc" -print-libgcc-file-name)")/include/limits.h"

    # Extract kernel headers
    cd "${build_dir}"

    unpack "${build_dir}" "${linux_kernel_url}"
    cd linux-"${linux_kernel_version}"
    apply_patches "${linux_kernel_url}"

    make mrproper
    make ARCH="$(uname -m)" \
        INSTALL_HDR_PATH="${target_dir}" \
        headers_install

    # Build musl
    cd "${build_dir}"

    unpack "${build_dir}" "${musl_url}"
    cd musl-"${musl_version}"
    apply_patches "${musl_url}"

    mkdirp build
    ../configure \
        --host="${cc_target}" \
        --prefix="${target_dir}" \
        --includedir="${target_dir}/include" \
        --syslibdir="${target_dir}/lib" \
        --disable-wrapper

    make
    make install

    # Build 2nd stage gcc
    cd "${build_dir}/gcc-${gcc_version}"
    rm -rf build
    mkdirp build
    ../configure \
        --prefix="${target_dir}" \
        --target="${cc_target}" \
        --includedir="${target_dir}/include" \
        --disable-libmudflap \
        --disable-libsanitizer \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --enable-default-pie \
        --enable-default-ssp \
        --enable-languages=c,c++ \
        --enable-tls \
        --with-local-prefix="${target_dir}/include" \
        --with-native-system-header-dir="/include" \
        --with-sysroot="${target_dir}"

    make
    make install

    # Check if gcc is actually working
    _testbin="$(mktemp /tmp/muslroot-crosstest.XXXXXX)"
    _testlog="$(mktemp /tmp/muslroot-crosstest.log.XXXXXX)"
    if ! (printf '%s' 'int main(){return 0;}' | "${cc_target}-gcc" -x c - -o "${_testbin}" -Wl,--verbose > "${_testlog}" 2>&1); then
        echo ">>> gcc failed to compile simple test program, dumping log"
        cat "${_testlog}"
        exit 1
    fi

    _libc="$("${cc_target}-readelf" -a "${_testbin}" | grep 'Requesting program interpreter' | sed 's#.*: \(.*\)\]#\1#')"
    if ! (printf '%s' "${_libc}" | grep -q "/lib/ld-musl-$(uname -m).so.*"); then
        echo ">>> gcc failed to link to musl libc"
        cat "${_testlog}"
        exit 1
    fi

    # Remove build directory to save space
    rm -rf "${build_dir}" || true
}

# Build m4
if has_quirk "build_own_m4"; then
    build_dir="$(create_tmp "host-m4")"
    cd "${build_dir}"

    unpack "${build_dir}" "${m4_url}"
    cd m4-"${m4_version}"
    apply_patches "${m4_url}"

    mkdirp build
    CFLAGS="-static" ../configure \
        --host="${cc_target}" \
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
    CFLAGS="-static" ../configure \
        --host="${cc_target}" \
        --prefix="${target_dir}"

    make
    make install
fi

# Mark stage finished
{
    echo ">>> Note: ignore following errors generated by 'strip' program"
    find "${target_dir}" -perm 755 '!' -type d '!' -name '*.la' -exec strip --strip-debug {} ';'
    date +%s > "${target_dir}/.finished"
}
