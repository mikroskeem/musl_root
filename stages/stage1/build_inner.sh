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

# Build mksh
{
    build_dir="$(create_tmp "mksh")"
    cd "${build_dir}"

    unpack "${build_dir}" "${mksh_url}"
    cd mksh
    apply_patches "${mksh_url}"

    sh ./Build.sh -j

    PREFIX="/usr"

    # Create directory structure
    install -d "${PREFIX}"/bin
    install -d /usr/share/doc/mksh/examples/

    # Copy files
    install -s -m 555 mksh "${PREFIX}"/bin/mksh
    install -m 444 dot.mkshrc /usr/share/doc/mksh/examples/

    # Symlink /usr/bin/sh to /usr/bin/mksh
    ln -sf "${PREFIX}"/bin/mksh "${PREFIX}"/bin/sh

    grep -x "${PREFIX}"/bin/mksh /etc/shells > /dev/null || \
        echo "${PREFIX}"/bin/mksh >> /etc/shells
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

    ./configure.gnu \
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

# Build openrc
{
    build_dir="$(create_tmp "openrc")"
    cd "${build_dir}"

    unpack "${build_dir}" "${openrc_url}"
    cd openrc-"${openrc_version}"
    apply_patches "${openrc_url}"

    make BRANDING="musl_root"
}
