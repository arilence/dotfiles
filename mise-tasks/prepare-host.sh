#!/usr/bin/env bash
# Provision NixOS onto a remote host using nixos-anywhere
#
# WARNING: This is a destructive operation that will wipe the target host!
#
# Mise Task Flags:
#MISE description="Provision NixOS onto a remote host (DESTRUCTIVE)"
#USAGE arg "<host>" help="Name of the NixOS host configuration. i.e. `desktop`"
#USAGE arg "<hostname>" help="Remote server's IP address or domain name"
#USAGE flag "-u --user <user>" help="Remote user on the target host" default="nixos"

set -euo pipefail

# Returns the directory where the script is located.
# We assume lib.sh is in the same directory as this script.
# From: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

HOST="${usage_host?}"
validate_host "${usage_host?}"
require_commands op nix ssh-keygen

FLAKE_DIR="$(project_root)"

echo "WARNING: this will permanently wipe and provision ${usage_hostname?} using host ${HOST}."
read -r -p "Continue? [y/N] " confirmation
case "${confirmation,,}" in
  y | yes) ;;
  *)
    echo "Host provisioning cancelled."
    exit 0
    ;;
esac

temp_etc=$(setup_ssh_host_key "${usage_host?}")
temp_luks=""

cleanup() {
  temp_dir_cleanup "$temp_etc"
  temp_dir_cleanup "$temp_luks"
}
trap cleanup EXIT INT TERM

temp_luks=$(setup_luks_passphrase "${usage_host?}")

echo "Running nixos-anywhere on ${usage_hostname?}"

# nixos-anywhere bypasses `~/.ssh/config` when executing `ssh-copy-id`, which for some people (myself)
# causes ssh to error out as I have more than the default (6) number of identities loaded.
# This figures out the identity file that ssh would use for the specified host. Basically what config does :/
# If no identity is used, it falls back to password authentication.
SSH_OPTS=()
SSH_IDENTITY=$(ssh -G "${usage_hostname?}" | awk '/^identityfile / {print $2; exit}')
SSH_IDENTITY="${SSH_IDENTITY/#\~/$HOME}"
if [[ -n "${SSH_IDENTITY}" && -f "${SSH_IDENTITY}" ]]; then
  SSH_OPTS+=(--ssh-option IdentitiesOnly=yes --ssh-option "IdentityFile=${SSH_IDENTITY}")
fi

nix run \
  github:nix-community/nixos-anywhere -- \
  --extra-files "$temp_etc" \
  --disk-encryption-keys /tmp/luks-passphrase "$temp_luks/tmp/luks-passphrase" \
  --flake "${FLAKE_DIR}#${usage_host?}" \
  "${SSH_OPTS[@]}" \
  --target-host "${usage_user}@${usage_hostname?}"

echo "Removing old host from known_hosts for ${usage_hostname?}"
ssh-keygen -R "${usage_hostname?}"

echo "Successfully provisioned ${usage_hostname?}"
