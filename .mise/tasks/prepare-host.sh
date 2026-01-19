#!/usr/bin/env bash
# Provision NixOS onto a remote host using nixos-anywhere
#
# WARNING: This is a destructive operation that will wipe the target host!
#
# Mise Task Flags:
#USAGE arg "<dir>" help="Name of directory where the nix flake is stored. i.e. `desktop`"
#USAGE arg "<hostname>" help="Remote server's IP address or domain name"

set -euo pipefail

# Returns the directory where the script is located.
# We assume lib.sh is in the same directory as this script.
# From: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/lib.sh"

validate_host_dir "${usage_dir?}"
require_commands op nix ssh-keygen

FLAKE_DIR="./nix"

echo "Setting up ssh private key"

# Create temp directory with restrictive permissions
temp_etc=$(mktemp -d)
chmod 700 "$temp_etc"
temp_luks=$(mktemp -d)
chmod 700 "$temp_luks"

cleanup() {
  if [[ -d "$temp_etc" ]]; then
    rm -rf "$temp_etc"
  fi
  if [[ -d "$temp_luks" ]]; then
    rm -rf "$temp_luks"
  fi
}
trap cleanup EXIT INT TERM

install -d -m700 "$temp_etc/etc/ssh"
install -d -m700 "$temp_luks/tmp"

# This *should* fail if the user denies the read request
echo "Reading SSH private key from 1Password..."
op_output_ssh=$(op read "op://Personal/${usage_dir?}/private key?ssh-format=openssh")
if [[ -z "$op_output_ssh" ]]; then
  echo "Error: Failed to read SSH private key from 1Password" >&2
  exit 1
fi
if [[ ! "$op_output_ssh" =~ ^-----BEGIN\ OPENSSH\ PRIVATE\ KEY----- ]]; then
  echo "Error: Invalid SSH private key format from 1Password" >&2
  exit 1
fi
echo "$op_output_ssh" > "$temp_etc/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp_etc/etc/ssh/ssh_host_ed25519_key"

# TODO: Create a function to read a secret from 1Password
echo "Reading LUKS passphrase from 1Password..."
op_output_luks=$(op read "op://Personal/${usage_dir?}/luks passphrase")
if [[ -z "$op_output_luks" ]]; then
  echo "Error: Failed to read LUKS passphrase from 1Password" >&2
  exit 1
fi
echo "$op_output_luks" > "$temp_luks/tmp/luks-passphrase"
chmod 600 "$temp_luks/tmp/luks-passphrase"

echo "Running nixos-anywhere on ${usage_hostname?}"

# TODO: Add a flag to specify the user to use for the target host
nix run \
  github:nix-community/nixos-anywhere -- \
  --extra-files "$temp_etc" \
  --disk-encryption-keys /tmp/luks-passphrase "$temp_luks/tmp/luks-passphrase" \
  --flake "${FLAKE_DIR}#${usage_dir?}" \
  --target-host "anthony@${usage_hostname?}"

echo "Removing old host from known_hosts for ${usage_hostname?}"
ssh-keygen -R "${usage_hostname?}"

echo "Successfully provisioned ${usage_hostname?}"
