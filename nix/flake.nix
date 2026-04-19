{
  inputs = {
    # Change the value of nixpkgs.url to set the NixOS version
    # List of available versions: https://channels.nixos.org/
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Elixir LSP
    expert.url = "github:elixir-lang/expert";
    expert.inputs.nixpkgs.follows = "nixpkgs";

    mise.url = "github:jdx/mise";
    mise.inputs.nixpkgs.follows = "nixpkgs";

    # Private Internet Access VPN
    pia.url = "github:arilence/pia.nix";
    pia.inputs.nixpkgs.follows = "nixpkgs";

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";

    # Session persistence for terminal processes
    zmx.url = "github:neurosnap/zmx";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      disko,
      sops-nix,
      home-manager,
      pia,
      claude-desktop,
      ...
    }@inputs:
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          {
            # Provides nixpkgs-unstable if needed for specific apps
            # i.e. can now use "pkgs.package" or "pkgs.unstable.package"
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit (final) config;
                  inherit (final.stdenv.hostPlatform) system;
                };
              })
            ];
          }
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          pia.nixosModules.default
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [ claude-desktop.overlays.default ];
              environment.systemPackages = [ pkgs.claude-desktop ];
            }
          )
          ./machines/desktop/configuration.nix
          # Use nixos-facter instead of nixos-generate-config
          { hardware.facter.reportPath = ./machines/desktop/facter.json; }
        ];
      };
    };
}
