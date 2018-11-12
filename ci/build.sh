#!/bin/sh

export DEBIAN_FRONTEND="noninteractive"
apt-get -y install \
    build-essential

cd musl_root || exit 1
./build.sh
