{
  inputs = {
    # Change the value of nixpkgs.url to set the NixOS version
    # List of available versions: https://channels.nixos.org/
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      disko,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./machines/desktop/configuration.nix
          # Use nixos-facter instead of nixos-generate-config
          { hardware.facter.reportPath = ./machines/desktop/facter.json; }
        ];
      };
    };
}
