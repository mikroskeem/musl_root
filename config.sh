#
# Script to configure builder
#

# Sources directory
sources="./sources"

# Patches directory
patches="./patches"

# Intermediate builds directory
tmpbuilds="./tmp/builds"

# Stages to build
stages="stage0 stage1 stage2"

# Whether stages should be compressed after
# being built or not. Takes more time, but
# saves disk space
compress_stages=YES

# Whether to use tmp or not
# Might speed up builds, but uses more RAM
use_tmp=YES

# Compiler/build tool flags
export MAKEFLAGS="-j$(grep -c ^processor /proc/cpuinfo)"
export CFLAGS="-fstack-protector-strong"
export XZ_FLAGS="-vvv"
