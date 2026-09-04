{
  config,
  lib,
  pkgs,
  ...
}:

let
  desktopWallpaper = ../../assets/wallpaper.png;
  primaryModifier = config.arilence.workstation.keybindings.primaryModifier;
in
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [
            "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
            "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
            "autoclose-xwayland" # automatically terminates Xwayland if all relevant X11 clients are gone
          ];
        };
        "org/gnome/shell" = {
          last-selected-power-profile = "performance";
          disable-user-extensions = false;
          disabled-extensions = "disabled";
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "dash-to-dock@micxgx.gmail.com"
          ];
          # Sets the apps to show in the "dock"
          # Use the following command to find the name of .desktop file:
          # ls /run/current-system/sw/share/applications/ | grep -i <appname>
          favorite-apps = [
            "org.gnome.Nautilus.desktop"
            "zen-beta.desktop"
            "obsidian.desktop"
            "discord-ptb.desktop"
            "spotify.desktop"
            "feishin.desktop"
            "kitty.desktop"
            "codex-desktop.desktop"
            "t3code.desktop"
          ];
        };
        "org/gnome/shell/window-switcher" = {
          current-workspace-only = false;
        };
        "org/gnome/desktop/session" = {
          idle-delay = lib.gvariant.mkUint32 0; # Disable screen timeout
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-light";
          enable-hot-corners = false;
          clock-show-date = true;
          clock-show-weekday = true;
        };
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 0.35;
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          click-method = "fingers";
          speed = 0.19;
          tap-to-click = true;
          tap-and-drag = false;
          natural-scroll = true;
        };
        "org/gtk/settings/file-chooser" = {
          clock-format = "24h";
        };
        "org/gnome/nautilus/preferences" = {
          show-image-thumbnails = "always";
        };
        "org/gnome/shell/extensions/dash-to-dock" = {
          multi-monitor = false;
          dock-position = "BOTTOM";
          intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
          height-fraction = 1.0;
          extend-height = false;
          dash-max-icon-size = lib.gvariant.mkInt32 48;
          show-running = true;
          isolate-workspaces = false;
          custom-theme-shrink = false;
          disable-overview-on-startup = true;
          apply-custom-theme = false;
          hot-keys = false;
          dock-fixed = false;
          require-pressure-to-show = true;
          intellihide = true;
          show-mounts-network = false;
          show-mounts-only-mounted = true;
          click-action = "focus-minimize-or-appspread";
        };

        # Desktop wallpaper
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://${desktopWallpaper}";
          picture-uri-dark = "file://${desktopWallpaper}";
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = "file://${desktopWallpaper}";
        };

        # Keybindings
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ "<Control><${primaryModifier}>h" ];
          toggle-tiled-right = [ "<Control><${primaryModifier}>l" ];
        };
        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = [ "<Shift><Super>s" ];
        };
        "org/gnome/desktop/wm/keybindings" = {
          # Disable default keybindings
          activate-window-menu = [ "disable" ];
          begin-move = [ "disable" ];
          begin-resize = [ "disable" ];
          minimize = [ "disable" ];
          toggle-maximized = [ "disable" ];
          switch-applications = [ "disable" ];
          switch-applications-backward = [ "disable" ];
          # Customize keybindings
          maximize = [ "<Control><${primaryModifier}>k" ];
          unmaximize = [ "<Control><${primaryModifier}>j" ];
          move-to-center = [ "<Control><${primaryModifier}>space" ];
          switch-windows = [ "<${primaryModifier}>Tab" ];
          switch-windows-backward = [ "<Shift><${primaryModifier}>Tab" ];
        }
        // lib.optionalAttrs (primaryModifier == "Super") {
          # Super+Space is GNOME's default input-source switcher. Disable it so
          # the host-specific Vicinae shortcut can claim the combination.
          switch-input-source = [ "disable" ];
          switch-input-source-backward = [ "disable" ];
        };
      };
    }
  ];

  # https://github.com/NixOS/nixpkgs/issues/149812
  # Fixes error: 'org.gtk.Settings.FileChooser' is not installed under GNOME.
  environment.sessionVariables.XDG_DATA_DIRS = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
  ];
}
