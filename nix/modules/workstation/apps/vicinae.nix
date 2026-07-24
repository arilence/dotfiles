{
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
          binding = "<Alt>space";
        };
      };
    }
  ];

  home-manager.users.anthony = {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
