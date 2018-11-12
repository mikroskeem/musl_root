#
# Source versions and urls
# Note: Prefer HTTPS urls to HTTP, unless you don't have SSL certificates
#

# Stage 0:
busybox_version="1.29.3"
musl_version="1.1.20"
sabotage_kernel_headers_version="3.12.6-6"

make_version="4.2.1"
libtool_version="2.4.6"
pkg_config_version="0.29.2"

# Stage 1:


# All urls
busybox_url="https://busybox.net/downloads/busybox-${busybox_version}.tar.bz2"
musl_url="https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz"
sabotage_kernel_headers_url="https://github.com/sabotage-linux/kernel-headers/archive/v${sabotage_kernel_headers_version}.tar.gz"
make_url="https://ftpmirror.gnu.org/make/make-${make_version}.tar.gz"
libtool_url="https://ftpmirror.gnu.org/libtool/libtool-${libtool_version}.tar.gz"
pkg_config_url="https://pkg-config.freedesktop.org/releases/pkg-config-${pkg_config_version}.tar.gz"
