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
