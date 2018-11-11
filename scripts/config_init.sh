#
# Initializes config
#

# Create directories
mkdir -p "${sources}"
mkdir -p "${tmpbuilds}"
mkdir -p "${patches}"

# Resolve absolute paths
sources="$(realpath "${sources}")"
tmpbuilds="$(realpath "${tmpbuilds}")"
patches="$(realpath "${patches}")"
