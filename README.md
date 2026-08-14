# dotfiles

My personal NixOS configurations, managed as a Nix flake with Home Manager.

Host-specific configurations live in `nix/machines`, while shared system and application modules live in `nix/modules`.

## Usage

With [Nix](https://nixos.org/) and [mise](https://mise.jdx.dev/) installed:

```bash
# Check a host configuration
mise run test-host desktop

# Rebuild the local machine
mise run rebuild-host desktop

# Provision a remote machine (destructive)
mise run prepare-host desktop <hostname>
```

Available hosts are defined in `flake.nix`.
