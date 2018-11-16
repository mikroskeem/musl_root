#
# Source versions and urls
# Note: Prefer HTTPS urls to HTTP, unless you don't have SSL certificates
#

# Stage 0:
busybox_version="1.29.3"
musl_version="1.1.20"
sabotage_kernel_headers_version="3.12.6-6"

make_version="4.2.1"
m4_version="1.4.18"
libtool_version="2.4.6"
pkg_config_version="0.29.2"
unshare_lite_version="0.1"

binutils_version="2.31.1"
gmp_version="6.1.2"
mpfr_version="4.0.1"
mpc_version="1.1.0"
gcc_version="8.2.0"

# Stage 1:
libexecinfo_version="1.1-2"
mksh_version="R56c"
libressl_version="2.8.2"
zlib_version="1.2.11"
curl_version="7.62.0"

# All urls
busybox_url="https://busybox.net/downloads/busybox-${busybox_version}.tar.bz2"
musl_url="https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz"
sabotage_kernel_headers_url="https://github.com/sabotage-linux/kernel-headers/archive/v${sabotage_kernel_headers_version}.tar.gz"
make_url="https://ftpmirror.gnu.org/make/make-${make_version}.tar.gz"
m4_url="https://ftpmirror.gnu.org/m4/m4-${m4_version}.tar.gz"
libtool_url="https://ftpmirror.gnu.org/libtool/libtool-${libtool_version}.tar.gz"
pkg_config_url="https://pkg-config.freedesktop.org/releases/pkg-config-${pkg_config_version}.tar.gz"
unshare_lite_url="https://github.com/mikroskeem/unshare-lite/archive/${unshare_lite_version}.tar.gz"
binutils_url="https://ftpmirror.gnu.org/binutils/binutils-${binutils_version}.tar.xz"
gcc_url="https://ftpmirror.gnu.org/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz"
gmp_url="https://ftpmirror.gnu.org/gmp/gmp-${gmp_version}.tar.xz"
mpfr_url="https://www.mpfr.org/mpfr-current/mpfr-${mpfr_version}.tar.xz"
mpc_url="https://ftpmirror.gnu.org/mpc/mpc-${mpc_version}.tar.gz"
libexecinfo_url="https://github.com/mikroskeem/libexecinfo/archive/${libexecinfo_version}.tar.gz"
mksh_url="https://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-${mksh_version}.tgz"
libressl_url="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${libressl_version}.tar.gz"
curl_url="https://curl.haxx.se/download/curl-${curl_version}.tar.gz"
zlib_url="https://zlib.net/zlib-${zlib_version}.tar.gz"
