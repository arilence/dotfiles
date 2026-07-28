{ config, pkgs, ... }:

let
  primaryModifier = config.arilence.workstation.keybindings.primaryModifier;
  inversePrimaryModifier = if primaryModifier == "Alt" then "Super" else "Alt";
in
{
  programs.niri.enable = true;

  environment.systemPackages = [
    # Xwayland support for apps like Steam
    pkgs.xwayland-satellite
  ];

  home-manager.users.anthony.xdg.configFile."niri/config.kdl".text = ''
    spawn-at-startup "noctalia"

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot From %Y-%m-%d %H-%M-%S.png"

    window-rule {
      match app-id="steam" title=r#"^Steam$"#
      open-maximized true
    }

    window-rule {
      match app-id="discord"
      open-maximized true
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

    binds {
      Mod+Space allow-inhibiting=false { spawn "${pkgs.vicinae}/bin/vicinae" "toggle"; }
      Mod+Q repeat=false allow-inhibiting=false { quit; }
      Mod+W repeat=false allow-inhibiting=false { close-window; }
      Mod+Ctrl+H allow-inhibiting=false { focus-column-left; }
      Mod+Ctrl+L allow-inhibiting=false { focus-column-right; }
      Mod+Ctrl+K allow-inhibiting=false { maximize-column; }
      Mod+Ctrl+Space allow-inhibiting=false { center-column; }
      Mod+Ctrl+M allow-inhibiting=false { fullscreen-window; }
      ${inversePrimaryModifier}+Shift+S { screenshot; }
      // Specifically set as Super rather than primaryModifier
      Super+L repeat=false allow-inhibiting=false { spawn "noctalia" "msg" "session" "lock"; }

      // Applications such as remote-desktop clients and software KVM switches may
      // request that niri stops processing the keyboard shortcuts defined here
      // so they may, for example, forward the key presses as-is to a remote machine.
      // It's a good idea to bind an escape hatch to toggle the inhibitor,
      // so a buggy application can't hold your session hostage.
      Mod+Ctrl+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
    }
  '';
}
