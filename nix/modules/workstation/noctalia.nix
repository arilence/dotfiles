{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.noctalia = {
    enable = true;

    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  home-manager.users.anthony = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      settings = {
        bar.main = {
          # Remove the end insets so the bar spans the screen width.
          margin_ends = 0;
          start = [ "workspaces" ];
        };

        theme.mode = "light";
      };
    };
  };
}
