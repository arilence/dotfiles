#!/usr/bin/env bash
# Print the hashes needed by nvidiaPackages.mkDriver for a driver release.
#
# Mise Task Flags:
#USAGE arg "<version>" help="NVIDIA driver version, e.g. 580.173.02"

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

require_commands nix jq

version="${usage_version?}"

prefetch_hash() {
  local url="$1"
  shift

  nix store prefetch-file --json "$@" "$url" | jq -r .hash
}

driver_hash=$(prefetch_hash \
  "https://us.download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run")
open_hash=$(prefetch_hash \
  "https://github.com/NVIDIA/open-gpu-kernel-modules/archive/${version}.tar.gz" \
  --unpack)
settings_hash=$(prefetch_hash \
  "https://github.com/NVIDIA/nvidia-settings/archive/${version}.tar.gz" \
  --unpack)
persistenced_hash=$(prefetch_hash \
  "https://github.com/NVIDIA/nvidia-persistenced/archive/${version}.tar.gz" \
  --unpack)

printf 'version = "%s";\n' "$version"
printf 'sha256_64bit = "%s";\n' "$driver_hash"
printf 'openSha256 = "%s";\n' "$open_hash"
printf 'settingsSha256 = "%s";\n' "$settings_hash"
printf 'persistencedSha256 = "%s";\n' "$persistenced_hash"
