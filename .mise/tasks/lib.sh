#!/usr/bin/env bash

set -euo pipefail

# Validate that a host directory exists and contains a flake.nix
# Arguments: $1 = host_dir name
validate_host_dir() {
  local host_dir="$1"
  local flake_dir="./nix"
  local machine_dir="${flake_dir}/machines/${host_dir}"

  if [[ ! -f "$flake_dir/flake.nix" ]]; then
    echo "Error: No flake.nix found in '$flake_dir'" >&2
    exit 1
  fi

  if [[ ! -d "$machine_dir" ]]; then
    echo "Error: Host directory '$flake_dir' does not exist" >&2
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

