#!/usr/bin/env bash
# Deploy NixOS flake changes to a remote host or local machine using nixos-rebuild
#
# Mise Task Flags:
#USAGE arg "<host>" help="Name of the NixOS host configuration. i.e. `desktop`"
#USAGE arg "[hostname]" help="Optional remote server's IP address or domain name. If omitted, rebuilds locally"
#USAGE flag "-b --boot" help="Make the configuration the default for the next boot without activating it"

set -euo pipefail

# Returns the directory where the script is located.
# We assume lib.sh is in the same directory as this script.
# From: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

validate_host "${usage_host?}"
require_commands nix

FLAKE_DIR="$(project_root)"

# Determine if this is a local or remote build
if [[ -n "${usage_hostname:-}" ]]; then
  IS_LOCAL_BUILD=false
  BUILD_TARGET="${usage_hostname}"
else
  IS_LOCAL_BUILD=true
  BUILD_TARGET="local machine"
fi

REBUILD_ACTION="switch"
if [[ "${usage_boot:-false}" == "true" ]]; then
  REBUILD_ACTION="boot"
fi

echo "Running nixos-rebuild ${REBUILD_ACTION} for ${BUILD_TARGET}..."

COMMAND_PREFIX="nix run nixpkgs#nixos-rebuild --"
if command -v nixos-rebuild >/dev/null 2>&1; then
  COMMAND_PREFIX="nixos-rebuild"
fi

# Build the command arguments based on local vs remote build
if [[ "${IS_LOCAL_BUILD}" == "true" ]]; then
  ${COMMAND_PREFIX} \
    "${REBUILD_ACTION}" \
    --flake "${FLAKE_DIR}#${usage_host?}" \
    --sudo \
    --ask-sudo-password
else
  ${COMMAND_PREFIX} \
    "${REBUILD_ACTION}" \
    --flake "${FLAKE_DIR}#${usage_host?}" \
    --target-host "anthony@${usage_hostname}" \
    --use-remote-sudo \
    --ask-sudo-password
fi

if [[ "${REBUILD_ACTION}" == "boot" ]]; then
  echo "Successfully made the new configuration the default for the next boot on ${BUILD_TARGET}"
  echo "Reboot ${BUILD_TARGET} to activate it"
else
  echo "Successfully deployed to ${BUILD_TARGET}"
  echo "You may need to manually reboot to apply all changes"
fi
