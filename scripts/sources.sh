#
# Source versions and urls
# Note: Prefer HTTPS urls to HTTP, unless you don't have SSL certificates
#

# shellcheck disable=SC2034

# Stage 0:
busybox_version="1.29.3"
musl_version="1.1.20"
linux_kernel_version="4.19.4"

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
perl_version="5.28.0"
gawk_version="4.2.1"
sed_version="4.5"
bison_version="3.2.1"
flex_version="2.6.4"
autoconf_version="2.69"
automake_version="1.16.1"
xz_version="5.2.4"
libarchive_version="3.3.3"
netbsd_curses_version="0.2.2"
libedit_version="20180525-3.1"
pcre_version="8.42"
grep_version="3.1"
coreutils_version="8.30"
bash_version="4.4"
_bash_patchlevel="023"
pacman_version="5.1.1"
libressl_version="2.8.2"
libz_version="1.2.8.2015.12.26"
curl_version="7.62.0"
pkgconf_version="1.5.4"
attr_version="2.4.48"
libcap_version="2.26"
fakeroot_version="1.23fixed"

# All urls
busybox_url="https://busybox.net/downloads/busybox-${busybox_version}.tar.bz2"
musl_url="https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz"
linux_kernel_url="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${linux_kernel_version}.tar.xz"
make_url="https://ftpmirror.gnu.org/make/make-${make_version}.tar.gz"
m4_url="https://ftpmirror.gnu.org/m4/m4-${m4_version}.tar.gz"
libtool_url="https://ftpmirror.gnu.org/libtool/libtool-${libtool_version}.tar.gz"
pkg_config_url="https://pkg-config.freedesktop.org/releases/pkg-config-${pkg_config_version}.tar.gz"
unshare_lite_url="unshare-lite-${unshare_lite_version}.tar.gz:https://github.com/mikroskeem/unshare-lite/archive/${unshare_lite_version}.tar.gz"
binutils_url="https://ftpmirror.gnu.org/binutils/binutils-${binutils_version}.tar.xz"
gcc_url="https://ftpmirror.gnu.org/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz"
gmp_url="https://ftpmirror.gnu.org/gmp/gmp-${gmp_version}.tar.xz"
mpfr_url="https://www.mpfr.org/mpfr-current/mpfr-${mpfr_version}.tar.xz"
mpc_url="https://ftpmirror.gnu.org/mpc/mpc-${mpc_version}.tar.gz"
libexecinfo_url="libexecinfo-${libexecinfo_version}.tar.gz:https://github.com/mikroskeem/libexecinfo/archive/${libexecinfo_version}.tar.gz"
perl_url="https://www.cpan.org/src/5.0/perl-${perl_version}.tar.gz"
gawk_url="https://ftp.gnu.org/gnu/gawk/gawk-${gawk_version}.tar.xz"
sed_url="https://ftp.gnu.org/gnu/sed/sed-${sed_version}.tar.xz"
bison_url="https://ftp.gnu.org/gnu/bison/bison-${bison_version}.tar.xz"
flex_url="flex-${flex_version}.tar.gz:https://github.com/westes/flex/releases/download/v${flex_version}/flex-${flex_version}.tar.gz"
autoconf_url="https://ftp.gnu.org/gnu/autoconf/autoconf-${autoconf_version}.tar.xz"
automake_url="https://ftp.gnu.org/gnu/automake/automake-${automake_version}.tar.xz"
xz_url="https://tukaani.org/xz/xz-${xz_version}.tar.xz"
libarchive_url="https://libarchive.org/downloads/libarchive-${libarchive_version}.tar.gz"
netbsd_curses_url="http://ftp.barfooze.de/pub/sabotage/tarballs/netbsd-curses-${netbsd_curses_version}.tar.xz"
libedit_url="http://thrysoee.dk/editline/libedit-${libedit_version}.tar.gz"
pcre_url="https://ftp.pcre.org/pub/pcre/pcre-${pcre_version}.tar.gz"
grep_url="https://ftp.gnu.org/gnu/grep/grep-${grep_version}.tar.xz"
coreutils_url="https://ftp.gnu.org/gnu/coreutils/coreutils-${coreutils_version}.tar.xz"
bash_url="https://ftp.gnu.org/gnu/bash/bash-${bash_version}.tar.gz"
pacman_url="https://sources.archlinux.org/other/pacman/pacman-${pacman_version}.tar.gz"
libressl_url="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${libressl_version}.tar.gz"
curl_url="https://curl.haxx.se/download/curl-${curl_version}.tar.gz"
libz_url="https://sortix.org/libz/release/libz-${libz_version}.tar.gz"
pkgconf_url="https://distfiles.dereferenced.org/pkgconf/pkgconf-${pkgconf_version}.tar.xz"
attr_url="https://download.savannah.gnu.org/releases/attr/attr-${attr_version}.tar.gz"
libcap_url="https://kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${libcap_version}.tar.xz"
fakeroot_url="fakeroot-${fakeroot_version}.tar.gz:https://github.com/mikroskeem/fakeroot/archive/${fakeroot_version}.tar.gz"
