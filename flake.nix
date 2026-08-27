{
  inputs = {
    # Change the value of nixpkgs.url to set the NixOS version
    # List of available versions: https://channels.nixos.org/
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Prefer to use nixOS-unstable when adding a package that's not yet available in stable nixpkgs.
    # nixPKGS-unstable is closer to the master branch and therefore has less rigorous testing.
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # <- prefer this one when unsure.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vicinae-extensions.url = "github:vicinaehq/extensions";
    vicinae-extensions.inputs.nixpkgs.follows = "nixpkgs";

    vicinae-music-links.url = "github:arilence/vicinae-music-links";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.home-manager.follows = "home-manager";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Private Internet Access VPN
    pia.url = "github:arilence/pia.nix";
    pia.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";

    # TODO: re-enable this once it has support for Niri and not just GNOME
    # # Provides variable scroll speed using a trackpad
    # wsf.url = "github:daniel-g-carrasco/wayland-scroll-factor";
    # wsf.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-unstable,
      nixpkgs-unstable,
      disko,
      nixos-hardware,
      sops-nix,
      home-manager,
      pia,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          system = "x86_64-linux";

          mkWorkstation =
            hostModules:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit inputs; };
              modules = [
                {
                  # Provides both unstable channels for selecting newer app versions.
                  nixpkgs.overlays = [
                    (final: prev: {
                      nixosUnstable = import nixos-unstable {
                        inherit (final) config;
                        inherit (final.stdenv.hostPlatform) system;
                      };
                      nixpkgsUnstable = import nixpkgs-unstable {
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
              ]
              ++ hostModules;
            };
        in
        {
          desktop = mkWorkstation [
            ./nix/machines/desktop/configuration.nix
            # Use nixos-facter instead of nixos-generate-config.
            { hardware.facter.reportPath = ./nix/machines/desktop/facter.json; }
          ];

          macbook = mkWorkstation [
            nixos-hardware.nixosModules.apple-macbook-pro-11-1
            ./nix/machines/macbook/configuration.nix
          ];
        };
    };
}
