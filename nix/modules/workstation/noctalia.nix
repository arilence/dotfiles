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

    # Noctalia can fail to discover audio devices, leaving the UI to display volume at 0%, if it
    # starts before WirePlumber discovers devices.
    # HACK: Order startup and allow time for the default sink.
    systemd.user.services.noctalia = {
      Unit = {
        Wants = [ "wireplumber.service" ];
        After = [
          "pipewire.service"
          "wireplumber.service"
        ];
      };
      Service.ExecStartPre = pkgs.writeShellScript "noctalia-wait-for-audio" ''
        for attempt in {1..50}; do
          if ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1; then
            exit 0
          fi
          ${pkgs.coreutils}/bin/sleep 0.1
        done
        # Still start the desktop shell when no audio output is connected.
        exit 0
      '';
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        # Manage plugins through Nix instead of background Git updates.
        plugins.auto_update = "none";

        bar.main = {
          # Disables opening the control center when right-clicking empty bar space.
          dead_zone.actions.right = "none";

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

        widget.media.hide_when_no_media = true;

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

        # TODO: should we handle starting these services inside their respective services file?
        hooks.started = [
          "${lib.getExe noctaliaPackage} msg wallpaper-set ${desktopWallpaper}"
          "${pkgs.systemd}/bin/systemctl --user start easyeffects.service"
          "${pkgs.systemd}/bin/systemctl --user start 1password.service"
          "${pkgs.systemd}/bin/systemctl --user start kopia-ui.service"
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
