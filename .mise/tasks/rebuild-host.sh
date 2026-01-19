#!/usr/bin/env bash
# Deploy NixOS flake changes to a remote host using nixos-rebuild
#
# Mise Task Flags:
#USAGE arg "<hostname>" help="Remote server's IP address or domain name"
#USAGE arg "<dir>" help="Name of directory where the nix flake is stored. i.e. `app-platform`"

set -euo pipefail

# Returns the directory where the script is located.
# We assume lib.sh is in the same directory as this script.
# From: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

validate_host_dir "${usage_dir?}"
require_commands nix

FLAKE_DIR="./nix"

echo "Deploying NixOS configuration to ${usage_hostname?}..."

COMMAND_PREFIX="nix run nixpkgs#nixos-rebuild --"
if command -v nixos-rebuild >/dev/null 2>&1; then
  COMMAND_PREFIX="nixos-rebuild"
fi

${COMMAND_PREFIX} \
  switch \
  --flake "${FLAKE_DIR}#${usage_dir?}" \
  --target-host "anthony@${usage_hostname?}" \
  --ask-sudo-password \
  --sudo

echo "Successfully deployed to ${usage_hostname?}"
echo "You may need to manually reboot to apply all changes"

