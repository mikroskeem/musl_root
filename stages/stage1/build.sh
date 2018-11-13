#
# Stage 1 build script
#
current_stage="stage1"

build_dir=""
target_dir="$(create_build_tmp)"

# Fetch sources
fetch "${busybox_url}"
fetch "${musl_url}"
fetch "${make_url}"
fetch "${libtool_url}"
fetch "${pkg_config_url}"
fetch "${sabotage_kernel_headers_url}"

# Prepare stage0 rootfs
{
    build_dir="$(create_tmp "base")"
    tar -C "${target_dir}" -xvf "$(get_stage_archive "stage0")"

    # Build stuff in musl_root environment
    bwrap --unshare-all --share-net \
        --die-with-parent \
        --bind "${target_dir}" / \
        --bind "${root_dir}" /musl_root \
        --uid 0 --gid 0 \
        --ro-bind /etc/resolv.conf /etc/resolv.conf \
        --symlink /usr/bin /bin \
        --symlink /usr/lib /lib \
        --tmpfs /tmp \
        --dev /dev \
        --proc /proc \
            /tools/bin/env -i \
                HOME=/ \
                PATH=/usr/bin:/tools/bin \
                    /tools/bin/ash \
                    /musl_root/stages/stage1/build_inner.sh

    exit 1
}
