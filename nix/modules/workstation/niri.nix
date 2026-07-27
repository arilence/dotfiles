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
      Mod+Ctrl+K allow-inhibiting=false { maximize-column; }
      Mod+Ctrl+Space allow-inhibiting=false { center-column; }
      Mod+Ctrl+M allow-inhibiting=false { fullscreen-window; }
      ${inversePrimaryModifier}+Shift+S { screenshot; }

      // Applications such as remote-desktop clients and software KVM switches may
      // request that niri stops processing the keyboard shortcuts defined here
      // so they may, for example, forward the key presses as-is to a remote machine.
      // It's a good idea to bind an escape hatch to toggle the inhibitor,
      // so a buggy application can't hold your session hostage.
      Mod+Ctrl+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
    }
  '';
}
