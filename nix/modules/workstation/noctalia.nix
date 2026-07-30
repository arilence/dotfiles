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
    inputs.noctalia-greeter.nixosModules.default
  ];

  environment.systemPackages = [
    noctaliaPackage
  ];

  programs.noctalia = {
    enable = true;

    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  programs.noctalia-greeter = {
    enable = true;

    # preselect niri
    greeter-args = "--session niri";

    # preselect user
    settings.user.default = "anthony";

    settings.cursor = {
      package = pkgs.adwaita-icon-theme;
      theme = "Adwaita";
      size = lib.mkDefault 24;
    };
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

        widget.clock.format = "{:%a %b %-d %H:%M}";

        theme.mode = "light";

        # Disables showing a notification every time media changes.
        osd.kinds.media = false;

        # Keep browser media sessions from overriding Spotify in the media widget.
        shell.mpris.blacklist = [
          "firefox"
          "zen"
        ];

        # Use Noctalia for graphical Polkit authentication prompts.
        shell.polkit_agent = true;

        shell.clipboard_enabled = true;

        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 600;
            action = "lock";
          };

          "screen-off" = {
            enabled = true;
            timeout = 660;
            action = "screen_off";
          };

          suspend = {
            enabled = true;
            timeout = 1800;
            action = "lock_and_suspend";
          };
        };

        hooks.started = [
          "${lib.getExe noctaliaPackage} msg wallpaper-set ${desktopWallpaper}"
        ]
        ++ lib.optionals config.arilence.workstation.apps.handy.autoStart [
          "${pkgs.systemd}/bin/systemctl --user start handy.service"
        ];

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
