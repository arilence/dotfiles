{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  desktopWallpaper = ../../assets/wallpaper.png;
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  environment.systemPackages = [
    noctaliaPackage
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

        hooks.started = "${lib.getExe noctaliaPackage} msg wallpaper-set ${desktopWallpaper}";

        wallpaper = {
          enabled = true;
          default.path = "${desktopWallpaper}";
        };
      };
    };
  };
}
