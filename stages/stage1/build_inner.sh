#!/bin/sh

# I dare you to run this on your host system.

set -e

cd /musl_root

. /musl_root/config.sh
. /musl_root/scripts/config_init.sh
. /musl_root/scripts/colors.sh
. /musl_root/scripts/sources.sh
. /musl_root/scripts/utils.sh

build_dir=""

# "Fix" missing ldconfig
cat > /usr/bin/ldconfig <<- EOF
#!/bin/sh
exit 0
EOF
chmod 755 /usr/bin/ldconfig

# Build libexecinfo
{
    build_dir="$(create_tmp "libexecinfo")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libexecinfo_url}"
    cd libexecinfo-"${libexecinfo_version}"
    apply_patches "${libexecinfo_url}"

    make CFLAGS="${CFLAGS} -fno-omit-frame-pointer" all
    make DESTDIR="/usr" install
}

# Build perl
{
    build_dir="$(create_tmp "perl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${perl_url}"
    cd perl-"${perl_version}"
    apply_patches "${perl_url}"

    oldcfl="${CFLAGS}"
    oldldf="${LDFLAGS}"
    oldmf="${MAKEFLAGS}"

    export LDFLAGS="-pthread ${LDFLAGS}"
    export CFLAGS="-D_GNU_SOURCE -DNO_POSIX_2008_LOCALE ${CFLAGS}"
    export MAKEFLAGS="$(printf '%s' "${MAKEFLAGS}" | sed 's/-j[0-9].* //g')"

    ./Configure -des \
        -Dusethreads -Duseshrplib -Dusesoname -Dusevendorprefix \
        -Dprefix=/usr -Dvendorprefix=/usr \
        -Dprivlib=/usr/share/perl5/core_perl \
        -Darchlib=/usr/lib/perl5/core_perl \
        -Dsitelib=/usr/share/perl5/site_perl \
        -Dsitearch=/usr/lib/perl5/site_perl \
        -Dvendorlib=/usr/share/perl5/vendor_perl \
        -Dvendorarch=/usr/lib/perl5/vendor_perl \
        -Dscriptdir=/usr/bin -Dvendorscript=/usr/bin \
        -Dinc_version_list=none -Dman1ext=1p -Dman3ext=3p \
        -Dman1dir=/usr/share/man/man1 \
        -Dman3dir=/usr/share/man/man3 \
        -Dd_sockaddr_in6=define \
        -Dcccdlflags="-fPIC" \
        -Doptimize=" -Wall ${CFLAGS} " -Dccflags=" ${CFLAGS} " \
        -Dlddlflags="-shared ${LDFLAGS}" -Dldflags="${LDFLAGS}" \
        -Dperl_static_inline='static __inline__' -Dd_static_inline

    make
    make install

     # Restore old env variables
     export CFLAGS="${oldcfl}"
     export LDFLAGS="${oldldf}"
     export MAKEFLAGS="${oldmf}"
}

# Build libressl
{
    build_dir="$(create_tmp "libressl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libressl_url}"
    cd libressl-"${libressl_version}"
    apply_patches "${libressl_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --with-openssldir=/etc/ssl

    make
    make install
}

# Build libz
{
    build_dir="$(create_tmp "libz")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libz_url}"
    cd libz-"${libz_version}"
    apply_patches "${libz_url}"

    mkdirp build
    ../configure \
        --prefix=/usr

    make
    make install
}

# Build gawk
{
    build_dir="$(create_tmp "gawk")"
    cd "${build_dir}"

    unpack "${build_dir}" "${gawk_url}"
    cd gawk-"${gawk_version}"
    apply_patches "${gawk_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-nls

    make
    make install
}

# Build sed
{
    build_dir="$(create_tmp "sed")"
    cd "${build_dir}"

    unpack "${build_dir}" "${sed_url}"
    cd sed-"${sed_version}"
    apply_patches "${sed_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-i18n \
        --disable-nls

    make
    make install
}

# Build bison
{
    build_dir="$(create_tmp "bison")"
    cd "${build_dir}"

    unpack "${build_dir}" "${bison_url}"
    cd bison-"${bison_version}"
    apply_patches "${bison_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-nls

    make
    make install
}

# Build flex
{
    build_dir="$(create_tmp "flex")"
    cd "${build_dir}"

    unpack "${build_dir}" "${flex_url}"
    cd flex-"${flex_version}"
    apply_patches "${flex_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-nls

    make
    make install
}

# Build autoconf
{
    build_dir="$(create_tmp "autoconf")"
    cd "${build_dir}"

    unpack "${build_dir}" "${autoconf_url}"
    cd autoconf-"${autoconf_version}"
    apply_patches "${autoconf_url}"

    mkdirp build
    ../configure \
        --prefix=/usr

    make
    make install
}

# Build automake
{
    build_dir="$(create_tmp "automake")"
    cd "${build_dir}"

    unpack "${build_dir}" "${automake_url}"
    cd automake-"${automake_version}"
    apply_patches "${automake_url}"

    mkdirp build
    ../configure \
        --prefix=/usr

    make
    make install
}

# Build pkgconf
{
    build_dir="$(create_tmp "pkgconf")"
    cd "${build_dir}"

    unpack "${build_dir}" "${pkgconf_url}"
    cd pkgconf-"${pkgconf_version}"
    apply_patches "${pkgconf_url}"

    _pcdirs=/usr/lib/pkgconfig:/usr/share/pkgconfig
    _libdir=/usr/lib
    _includedir=/usr/include

    mkdirp build
    ../configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --with-pkg-config-dir="${_pcdirs}" \
        --with-system-libdir="${_libdir}" \
        --with-system-includedir="${_includedir}"

    make
    make install

    # Install pkg-config compatibility script
    # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/pkgconf#n55
    install -D /dev/stdin "/usr/bin/$(uname -m)-pkg-config" <<EOF
#!/bin/sh

# Simple wrapper to tell pkgconf to behave as a platform-specific version of pkg-config
# Platform: $(uname -m)-unknown-linux-musl

: \${PKG_CONFIG_LIBDIR=${_pcdirs}}
: \${PKG_CONFIG_SYSTEM_LIBRARY_PATH=${_libdir}}
: \${PKG_CONFIG_SYSTEM_INCLUDE_PATH=${_includedir}}
export PKG_CONFIG_LIBDIR PKG_CONFIG_SYSTEM_LIBRARY_PATH PKG_CONFIG_SYSTEM_INCLUDE_PATH

exec pkgconf "\$@"
EOF

    ln -s "$(uname -m)-pkg-config" "/usr/bin/pkg-config"
}

# Build xz
{
    build_dir="$(create_tmp "xz")"
    cd "${build_dir}"

    unpack "${build_dir}" "${xz_url}"
    cd xz-"${xz_version}"
    apply_patches "${xz_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-nls

    make
    make install
}

# Build libarchive
{
    build_dir="$(create_tmp "libarchive")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libarchive_url}"
    cd libarchive-"${libarchive_version}"
    apply_patches "${libarchive_url}"

    mkdirp _build
    ../configure \
        --prefix=/usr

    make
    make install
}

# Build netbsd-curses
{
    build_dir="$(create_tmp "netbsd-curses")"
    cd "${build_dir}"

    unpack "${build_dir}" "${netbsd_curses_url}"
    cd netbsd-curses-"${netbsd_curses_version}"
    apply_patches "${netbsd_curses_url}"

    make \
        PREFIX=/usr \
        CFLAGS="${CFLAGS} -fPIC"

    make PREFIX=/usr install
}

# Build libedit
{
    build_dir="$(create_tmp "libedit")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libedit_url}"
    cd libedit-"${libedit_version}"
    apply_patches "${libedit_url}"

    mkdirp build
    ../configure \
        --prefix=/usr

    make
    make install
}

# Build pcre
{
    build_dir="$(create_tmp "pcre")"
    cd "${build_dir}"

    unpack "${build_dir}" "${pcre_url}"
    cd pcre-"${pcre_version}"
    apply_patches "${pcre_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --enable-utf8 \
        --enable-jit \
        --enable-pcretest-libedit \
        --enable-pcregrep-libz

    make
    make install
}

# Build grep
{
    build_dir="$(create_tmp "grep")"
    cd "${build_dir}"

    unpack "${build_dir}" "${grep_url}"
    cd grep-"${grep_version}"
    apply_patches "${grep_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-nls

    make
    make install
}

# Build coreutils
{
    build_dir="$(create_tmp "coreutils")"
    cd "${build_dir}"

    unpack "${build_dir}" "${coreutils_url}"
    cd coreutils-"${coreutils_version}"
    apply_patches "${coreutils_url}"

    mkdirp build
    FORCE_UNSAFE_CONFIGURE=1 ../configure \
        --prefix=/usr \
        --disable-nls

    make
    make install
}

# Build bash
{
    build_dir="$(create_tmp "bash")"
    cd "${build_dir}"

    unpack "${build_dir}" "${bash_url}"
    cd bash-"${bash_version}"

    # Apply incremental patches first
    find "/musl_root/patches/bash-${bash_version}" -type f -name "bash*.diff" -exec patch -p0 -i {} ';'

    apply_patches "${bash_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-nls \
        --without-bash-malloc

    # TODO: not compatible with libedit and netbsd-curses?

    make
    make install

    # Symlink sh to bash
    ln -sf bash /usr/bin/sh

    grep -q -x /usr/bin/bash /etc/shells || \
        echo /usr/bin/bash >> /etc/shells
}

# Build pacman
{
    build_dir="$(create_tmp "pacman")"
    cd "${build_dir}"

    unpack "${build_dir}" "${pacman_url}"
    cd pacman-"${pacman_version}"
    apply_patches "${pacman_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --disable-nls \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --with-scriptlet-shell=/usr/bin/bash \
        --with-ldconfig=/usr/bin/ldconfig

    make
    make install
}

# Build curl
{
    build_dir="$(create_tmp "curl")"
    cd "${build_dir}"

    unpack "${build_dir}" "${curl_url}"
    cd curl-"${curl_version}"
    apply_patches "${curl_url}"

    mkdirp build
    ../configure \
        --prefix=/usr \
        --mandir=/usr/share/man \
        --disable-dict \
        --disable-gopher \
        --disable-imap \
        --disable-ldap \
        --disable-ldaps \
        --disable-manual \
        --disable-pop3 \
        --disable-rtsp \
        --disable-smb \
        --disable-smtp \
        --disable-telnet \
        --disable-tftp \
        --enable-threaded-resolver \
        --enable-versioned-symbols \
        --with-random=/dev/urandom \
        --with-ssl \
        --with-zlib \
        --without-gssapi \
        --without-libidn2 \
        --without-libmetalink \
        --without-libpsl \
        --without-rtmp \
        --without-zsh-functions-dir

    make
    make install
}

# Build attr
{
    build_dir="$(create_tmp "attr")"
    cd "${build_dir}"

    unpack "${build_dir}" "${attr_url}"
    cd attr-"${attr_version}"
    apply_patches "${attr_url}"

    ./configure \
        --libdir=/usr/lib \
        --libexecdir=/usr/lib \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-gettext

    make
    make install
}

# Build libcap
{
    build_dir="$(create_tmp "libcap")"
    cd "${build_dir}"

    unpack "${build_dir}" "${libcap_url}"
    cd libcap-"${libcap_version}"
    apply_patches "${libcap_url}"

    sed -i "/SBINDIR/s#sbin#bin#" Make.Rules
    sed -i "s/CFLAGS :=/CFLAGS += \$(CPPFLAGS) /" Make.Rules
    sed -i "s/LDFLAGS :=/LDFLAGS +=/" Make.Rules

    make prefix=/usr lib=lib KERNEL_HEADERS=/usr/include
    make prefix=/usr lib=/lib DESTDIR="${pkgdir}" RAISE_SETFCAP=no install
}

# Build fakeroot
{
    build_dir="$(create_tmp "fakeroot")"
    cd "${build_dir}"

    unpack "${build_dir}" "${fakeroot_url}"
    cd fakeroot-"${fakeroot_version}"
    apply_patches "${fakeroot_url}"

    libtoolize
    ./bootstrap
    ./configure \
        --prefix=/usr \
        --disable-static \
        --with-ipc=tcp

    make

    for l in de es fr nl pt sv; do
        touch "doc/${l}/faked.1"
        touch "doc/${l}/fakeroot.1"
    done

    make install
}

# Final steps
{
    # Configure pacman and makepkg
    sed -i '/^#XferCommand = .*curl/{s/^#//}' /etc/pacman.conf
    sed -i '/^#Color/{s/^#//}' /etc/pacman.conf
    sed -i '/^#VerbosePkgLists/{s/^#//}' /etc/pacman.conf

    sed -i "/^CHOST/{s/.*/CHOST=\"$(uname -m)-unknown-linux-musl\"/}" /etc/makepkg.conf
    sed -i "/^PKGEXT/{s/.*/PKGEXT='.pkg.tar.xz'/}" /etc/makepkg.conf
    sed -i "/^SRCEXT/{s/.*/SRCEXT='.src.tar.xz'/}" /etc/makepkg.conf
    sed -i "/^INTEGRITY_CHECK=.*/{s/(.*/(sha256)/}" /etc/makepkg.conf

    # Set up /etc/profile
    printf "PATH=/usr/bin:/tools/bin\\nexport PATH\\n" | install -m 644 /dev/stdin /etc/profile
}
