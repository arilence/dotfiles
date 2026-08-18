{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.noctalia-greeter = {
    enable = true;

    # Preselect Niri.
    greeter-args = "--session niri";

    # Preselect the primary user.
    settings.user.default = "anthony";

    settings.cursor = {
      path = "${pkgs.adwaita-icon-theme}/share/icons";
      theme = "Adwaita";
      size = lib.mkDefault 24;
    };
  };
}
