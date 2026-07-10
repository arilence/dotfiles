#!/usr/bin/env bash
# Check for issues with NixOS configuration using dry-build
#
# Mise Task Flags:
#USAGE arg "<host>" help="Name of the NixOS host configuration. i.e. `desktop`"

set -euo pipefail

# Returns the directory where the script is located.
# We assume lib.sh is in the same directory as this script.
# From: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

validate_host "${usage_host?}"
require_commands nix

FLAKE_DIR="$(project_root)"

echo "Testing NixOS configuration for ${usage_host?}"

COMMAND_PREFIX="nix run nixpkgs#nixos-rebuild --"
if command -v nixos-rebuild >/dev/null 2>&1; then
  COMMAND_PREFIX="nixos-rebuild"
fi

${COMMAND_PREFIX} \
  dry-build \
  --flake "${FLAKE_DIR}#${usage_host?}"

echo "Configuration test passed for ${usage_host?}"
