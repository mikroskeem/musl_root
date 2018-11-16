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
libexecinfo_url="https://github.com/mikroskeem/libexecinfo/archive/${libexecinfo_version}.tar.gz"
mksh_url="https://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-${mksh_version}.tgz"
libressl_url="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${libressl_version}.tar.gz"
curl_url="https://curl.haxx.se/download/curl-${curl_version}.tar.gz"
zlib_url="https://zlib.net/zlib-${zlib_version}.tar.gz"
