#!/usr/bin/env bash

set -euo pipefail

# Return the repository root. Mise provides MISE_PROJECT_ROOT; when the script is
# run directly, fall back to the parent directory of mise-tasks.
project_root() {
  if [[ -n "${MISE_PROJECT_ROOT:-}" ]]; then
    echo "${MISE_PROJECT_ROOT}"
  else
    cd "${SCRIPT_DIR}/.." && pwd
  fi
}

# Validate that a host exists in nix/machines and can be referenced from the root flake.
# Arguments: $1 = host name
validate_host() {
  local host="$1"
  local root
  root="$(project_root)"
  local host_dir="${root}/nix/machines/${host}"
  local root_flake="${root}/flake.nix"

  if [[ ! -f "$root_flake" ]]; then
    echo "Error: Root flake '$root_flake' does not exist" >&2
    exit 1
  fi

  if [[ ! -d "$host_dir" ]]; then
    echo "Error: Host directory '$host_dir' does not exist" >&2
    exit 1
  fi

  if [[ ! -f "$host_dir/configuration.nix" ]]; then
    echo "Error: No configuration.nix found in '$host_dir'" >&2
    exit 1
  fi
}

# Validate that required commands are available
# Arguments: $@ = list of command names
require_commands() {
  for cmd in "$@"; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Error: Required command '$cmd' not found" >&2
      exit 1
    fi
  done
}

# Validate that a port number is valid (1-65535)
# Arguments: $1 = port number
validate_port() {
  local port="$1"

  if ! [[ "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
    echo "Error: Port '$port' must be a number between 1 and 65535" >&2
    exit 1
  fi
}

temp_dir_cleanup() {
  local temp_dir="${1}"
  if [[ -d "$temp_dir" ]]; then
    rm -rf "$temp_dir"
  fi
}

# Reads SSH host key from 1Password into a temp directory.
# Arguments: $1 = host (Name of SSH key inside of 1Password vault)
# Returns: temp_dir path
setup_ssh_host_key() {
  local host="$1"

  echo "Setting up ssh private key" >&2

  # Create temp directory with restrictive permissions
  local temp_dir
  temp_dir=$(mktemp -d)
  chmod 700 "$temp_dir"

  install -d -m700 "$temp_dir/etc/ssh"

  # This *should* fail if the user denies the read request
  echo "Reading SSH private key from 1Password..." >&2
  local op_output
  if ! op_output=$(op read "op://Personal/${host}/private key?ssh-format=openssh"); then
    echo "Error: Failed to read SSH private key from 1Password" >&2
    temp_dir_cleanup "$temp_dir"
    return 1
  fi

  if [[ -z "$op_output" ]]; then
    echo "Error: Failed to read SSH private key from 1Password" >&2
    temp_dir_cleanup "$temp_dir"
    return 1
  fi

  if [[ ! "$op_output" =~ ^-----BEGIN\ OPENSSH\ PRIVATE\ KEY----- ]]; then
    echo "Error: Invalid SSH private key format from 1Password" >&2
    temp_dir_cleanup "$temp_dir"
    return 1
  fi

  printf '%s\n' "$op_output" > "$temp_dir/etc/ssh/ssh_host_ed25519_key"
  chmod 600 "$temp_dir/etc/ssh/ssh_host_ed25519_key"

  echo "$temp_dir"
}

# Reads a LUKS passphrase from 1Password into a temp directory.
# Arguments: $1 = host (Name of the 1Password item containing the passphrase)
# Returns: temp_dir path
setup_luks_passphrase() {
  local host="$1"

  local temp_dir
  temp_dir=$(mktemp -d)
  chmod 700 "$temp_dir"

  install -d -m700 "$temp_dir/tmp"

  echo "Reading LUKS passphrase from 1Password..." >&2
  local op_output
  if ! op_output=$(op read "op://Personal/${host}/luks passphrase"); then
    echo "Error: Failed to read LUKS passphrase from 1Password" >&2
    temp_dir_cleanup "$temp_dir"
    return 1
  fi

  if [[ -z "$op_output" ]]; then
    echo "Error: Failed to read LUKS passphrase from 1Password" >&2
    temp_dir_cleanup "$temp_dir"
    return 1
  fi

  printf '%s\n' "$op_output" > "$temp_dir/tmp/luks-passphrase"
  chmod 600 "$temp_dir/tmp/luks-passphrase"

  echo "$temp_dir"
}
