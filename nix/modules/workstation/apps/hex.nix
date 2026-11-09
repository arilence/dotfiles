{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  modifier =
    if config.arilence.workstation.keybindings.primaryModifier == "Super" then "super" else "alt";
in
{
  home-manager.users.anthony = {
    imports = [ inputs.hex.homeManagerModules.hex ];
    programs.hex = {
      enable = true;
      package = pkgs.nixosUnstable.anomaly-hex;
      autostart = lib.mkDefault true;
      shortcut = "${modifier}+shift+space";
      model = "parakeet_unified_en";
      language = "en";
      installModel = true;
      settings = {
        shortcut_mode = "toggle";
        "labs.unload_idle" = true;
      };
    };
  };
}
