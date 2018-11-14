#!/bin/sh

# I dare you to run this on your host system.

set -e

cd /musl_root

. /musl_root/config.sh
. /musl_root/scripts/config_init.sh
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
