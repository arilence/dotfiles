#!/usr/bin/env bash
# Deploy NixOS flake changes to a remote host or local machine using nixos-rebuild
#
# Mise Task Flags:
#USAGE arg "<dir>" help="Name of directory where the nix flake is stored. i.e. `desktop`"
#USAGE arg "[hostname]" help="Optional remote server's IP address or domain name. If omitted, rebuilds locally"

set -euo pipefail

# Returns the directory where the script is located.
# We assume lib.sh is in the same directory as this script.
# From: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

validate_host_dir "${usage_dir?}"
require_commands nix

FLAKE_DIR="./nix"

# Determine if this is a local or remote build
if [[ -n "${usage_hostname:-}" ]]; then
  IS_LOCAL_BUILD=false
  BUILD_TARGET="${usage_hostname}"
else
  IS_LOCAL_BUILD=true
  BUILD_TARGET="local machine"
fi

echo "Deploying NixOS configuration to ${BUILD_TARGET}..."

COMMAND_PREFIX="nix run nixpkgs#nixos-rebuild --"
if command -v nixos-rebuild >/dev/null 2>&1; then
  COMMAND_PREFIX="nixos-rebuild"
fi

# Build the command arguments based on local vs remote build
if [[ "${IS_LOCAL_BUILD}" == "true" ]]; then
  ${COMMAND_PREFIX} \
    switch \
    --flake "${FLAKE_DIR}#${usage_dir?}" \
    --sudo \
    --ask-sudo-password
else
  ${COMMAND_PREFIX} \
    switch \
    --flake "${FLAKE_DIR}#${usage_dir?}" \
    --target-host "anthony@${usage_hostname}" \
    --use-remote-sudo \
    --ask-sudo-password
fi

echo "Successfully deployed to ${BUILD_TARGET}"
echo "You may need to manually reboot to apply all changes"

