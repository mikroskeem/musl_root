#
# Stage 1 build script
#
current_stage="stage1"

build_dir=""
target_dir="$(create_build_tmp)"

# Fetch sources
fetch "${busybox_url}"
fetch "${make_url}"
fetch "${libtool_url}"

fetch "${libexecinfo_url}"
fetch "${perl_url}"
fetch "${libressl_url}"
fetch "${libz_url}"
fetch "${gawk_url}"
fetch "${sed_url}"
fetch "${bison_url}"
fetch "${flex_url}"
fetch "${automake_url}"
fetch "${autoconf_url}"
fetch "${xz_url}"
fetch "${libarchive_url}"
fetch "${netbsd_curses_url}"
fetch "${libedit_url}"
fetch "${pcre_url}"
fetch "${grep_url}"
fetch "${coreutils_url}"
fetch "${bash_url}"
fetch "${pacman_url}"
fetch "${curl_url}"
fetch "${pkgconf_url}"
fetch "${attr_url}"
fetch "${libcap_url}"
fetch "${fakeroot_url}"

# Fetch bash incremental patches
{
    _oldpwd="$(pwd)"
    cd "${root_dir}/patches/bash-${bash_version}" || exit 1
    bash fetch-incr.sh "${bash_version}" "${_bash_patchlevel}"
    cd "${_oldpwd}" || exit 1
}

# Prepare stage0 rootfs
{
    build_dir="$(create_tmp "base")"
    inform "Unpacking stage0"
    tar -C "${target_dir}" -xf "$(get_stage_archive "stage0")"

    # Build stuff in musl_root environment
    if ! has_quirk "unisolated_stage_build"; then
        bwrap --unshare-all --share-net \
            --die-with-parent \
            --bind "${target_dir}" / \
            --bind "${root_dir}" /musl_root \
            --uid 0 --gid 0 \
            --ro-bind /etc/resolv.conf /etc/resolv.conf \
            --tmpfs /tmp \
            --dev /dev \
            --proc /proc \
                /tools/bin/env -i \
                    HOME=/ \
                    PATH=/usr/bin:/tools/bin \
                        /tools/bin/ash \
                        /musl_root/stages/stage1/build_inner.sh
    else
        # TODO: improve chroot fallback
        _resolv="$(cat /etc/resolv.conf 2>/dev/null || printf 'nameserver 1.1.1.1\nnameserver 1.0.0.1')";
        printf "%s" "${_resolv}" > "${target_dir}"/etc/resolv.conf
        chroot "${target_dir}" \
                /tools/bin/env -i \
                    HOME=/ \
                    PATH=/usr/bin:/tools/bin \
                        /tools/bin/ash \
                        /musl_root/stages/stage1/build_inner.sh
        rm "${target_dir}"/etc/resolv.conf
    fi
}
