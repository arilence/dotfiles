{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true;
      settings = {
        "org/gnome/shell/keybindings" = {
          toggle-overview = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae" = {
          name = "Toggle Vicinae";
          command = "${pkgs.vicinae}/bin/vicinae toggle";
          binding = "<${config.arilence.workstation.keybindings.primaryModifier}>space";
        };
      };
    }
  ];

  home-manager.users.anthony =
    { config, ... }:
    {
      programs.vicinae = {
        enable = true;
        extensions = [
          inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.nix
          inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.timer
          # Add Raycast extensions with:
          # config.lib.vicinae.mkRayCastExtension
        ];
        systemd = {
          enable = true;
          autoStart = true;
        };
      };
    };
}
