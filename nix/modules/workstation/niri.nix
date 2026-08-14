{ config, pkgs, ... }:

let
  primaryModifier = config.arilence.workstation.keybindings.primaryModifier;
  inversePrimaryModifier = if primaryModifier == "Alt" then "Super" else "Alt";
in
{
  programs.niri.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session.user = "greeter";
  };

  environment.systemPackages = [
    # Xwayland support for apps like Steam
    pkgs.xwayland-satellite
  ];

  home-manager.users.anthony = {
    home.pointerCursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    xdg.configFile."niri/config.kdl".text = ''
      spawn-at-startup "noctalia"

      workspace "media"
      workspace "main"

      spawn-at-startup "niri" "msg" "action" "focus-workspace" "main"

      prefer-no-csd

      screenshot-path "~/Pictures/Screenshots/Screenshot From %Y-%m-%d %H-%M-%S.png"

      cursor {
        xcursor-theme "Adwaita"
        xcursor-size 24
      }

      hotkey-overlay {
        skip-at-startup
      }

      layout {
          always-center-single-column
      }

      debug {
        // Allows notification actions and window activation from Noctalia.
        honor-xdg-activation-with-invalid-serial
      }

      // Disable blurred wallpaper on overview screen
      layer-rule {
        match namespace="^noctalia-backdrop"
        place-within-backdrop true
      }

      input {
        mod-key "${primaryModifier}"

        touchpad {
          natural-scroll
        }

        mouse {
          accel-profile "flat"
          accel-speed 0.35
        }
      }

      switch-events {
        lid-close { spawn "noctalia" "msg" "session" "lock-and-suspend"; }
      }

      recent-windows {
        previews {
          max-height 240
          max-scale 0.25
        }
      }

      binds {
        Mod+Space allow-inhibiting=false { spawn "${pkgs.vicinae}/bin/vicinae" "toggle"; }
        Mod+Q repeat=false allow-inhibiting=false { quit; }
        Mod+W repeat=false allow-inhibiting=false { close-window; }
        ${inversePrimaryModifier}+Shift+S { screenshot; }
        // Specifically set as Super rather than primaryModifier
        Super+L repeat=false allow-inhibiting=false { spawn "noctalia" "msg" "session" "lock"; }

        // Handy speech-to-text. Press once to record and again to transcribe.
        Mod+Shift+Space repeat=false allow-inhibiting=false { spawn "handy-toggle"; }

        // Window management
        Mod+Ctrl+H allow-inhibiting=false { focus-column-left; }
        Mod+Ctrl+L allow-inhibiting=false { focus-column-right; }
        Mod+Ctrl+K allow-inhibiting=false { focus-workspace-up; }
        Mod+Ctrl+J allow-inhibiting=false { focus-workspace-down; }
        Mod+Ctrl+Space allow-inhibiting=false { center-column; }
        Mod+Ctrl+Shift+K allow-inhibiting=false { maximize-column; }
        Mod+Ctrl+Shift+F allow-inhibiting=false { fullscreen-window; }

        // Applications such as remote-desktop clients and software KVM switches may
        // request that niri stops processing the keyboard shortcuts defined here
        // so they may, for example, forward the key presses as-is to a remote machine.
        // It's a good idea to bind an escape hatch to toggle the inhibitor,
        // so a buggy application can't hold your session hostage.
        Mod+Ctrl+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        // Audio & Brightness
        XF86AudioRaiseVolume { spawn-sh "noctalia msg volume-up"; }
        XF86AudioLowerVolume { spawn-sh "noctalia msg volume-down"; }
        XF86AudioMute { spawn-sh "noctalia msg volume-mute"; }
        XF86MonBrightnessUp { spawn-sh "noctalia msg brightness-up"; }
        XF86MonBrightnessDown { spawn-sh "noctalia msg brightness-down"; }
      }

      // Catch-all Rule
      window-rule {
        // Rounded corners for a modern look.
        geometry-corner-radius 10

        // Clips window contents to the rounded corner boundaries.
        clip-to-geometry true
      }

      // Floating Noctalia settings window.
      window-rule {
        match app-id="dev.noctalia.Noctalia"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
      }

      window-rule {
        match app-id="zen-beta"
        open-maximized true
        open-focused true
      }

      window-rule {
        match app-id="obsidian"
        open-maximized true
        open-focused true
      }

      window-rule {
        match app-id="kitty"
        open-maximized true
        open-focused true
      }

      window-rule {
        match app-id="steam" title=r#"^Steam$"#
        open-maximized true
      }

      window-rule {
        match app-id="discord"
        open-maximized true
        open-on-workspace "media"
        open-focused true
      }

      window-rule {
        match app-id="Spotify"
        open-on-workspace "media"
        open-focused true
      }

      // Keep Android Emulator windows in the tiled layout.
      // Fixes the toolbar from floating in the center of the screen.
      window-rule {
        match app-id="Emulator"
        open-floating false
      }
      window-rule {
        match app-id="Emulator" title=r#"^Android Emulator - "#
        tiled-state true
        default-column-width {}
      }

      window-rule {
        match app-id="steam" title=r#"^notificationtoasts_\d+_desktop$"#
        default-floating-position x=10 y=10 relative-to="bottom-right"
      }

      // Keep Proton and conventionally identified Steam game windows out of
      // the always-on-top floating layout.
      window-rule {
        match app-id=r#"(?i)\.exe$"#
        match app-id=r#"^steam_app_[0-9]+$"#
        open-floating false
      }
    '';
  };
}
