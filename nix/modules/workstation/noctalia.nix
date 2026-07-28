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
          # Keep the top bar flush and square against the screen edges.
          radius = 0;

          # Remove the end insets so the bar spans the screen width.
          margin_ends = 0;
          widget_spacing = 12;
          start = [
            "workspaces"
            "weather"
            "media"
          ];
          center = [
            "clock"
            "notifications"
          ];
          end = [
            "tray"
            "network"
            "volume"
            "battery"
            "control-center"
            "session"
          ];
        };

        widget.clock.format = "{:%b %-d %H:%M}";

        theme.mode = "light";

        # Disables showing a notification every time media changes.
        osd.kinds.media = false;

        # Keep browser media sessions from overriding Spotify in the media widget.
        shell.mpris.blacklist = [
          "firefox"
          "zen"
        ];

        hooks.started = "${lib.getExe noctaliaPackage} msg wallpaper-set ${desktopWallpaper}";

        location = {
          auto_locate = true;
        };

        weather = {
          enabled = true;
          unit = "metric";
        };

        wallpaper = {
          enabled = true;
          default.path = "${desktopWallpaper}";
        };
      };
    };
  };
}
