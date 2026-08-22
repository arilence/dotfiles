{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  desktopWallpaper = ../../assets/wallpaper.png;

  # Match Noctalia's built-in light palette.
  noctaliaLightPalette = {
    primary = "#5d65f5";
    on_primary = "#dadcff";
    secondary = "#8e93d8";
    on_secondary = "#dadcff";
    tertiary = "#0e0e43";
    on_tertiary = "#fef29a";
    error = "#fd4663";
    on_error = "#0e0e43";
    surface = "#e6e8fa";
    on_surface = "#0e0e43";
    surface_variant = "#eff0ff";
    on_surface_variant = "#4b55c8";
    outline = "#8288fc";
    shadow = "#f3edf7";
    hover = "#0e0e43";
    on_hover = "#fef29a";
  };
in
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.noctalia-greeter = {
    enable = true;

    # Preselect Niri.
    greeter-args = "--session niri";

    # Preselect the primary user.
    settings = {
      user.default = "anthony";

      appearance = {
        scheme = "Synced";
        theme_mode = "light";
        palette = noctaliaLightPalette;
        wallpaper = {
          path = "${desktopWallpaper}";
          fill_mode = "crop";
        };
      };

      cursor = {
        path = "${pkgs.adwaita-icon-theme}/share/icons";
        theme = "Adwaita";
        size = lib.mkDefault 24;
      };
    };
  };
}
