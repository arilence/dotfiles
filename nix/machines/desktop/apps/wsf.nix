{
  inputs,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    inputs.wsf.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home-manager.users.anthony.xdg.configFile."wayland-scroll-factor/config".text = ''
    scroll_vertical_factor=0.35
    scroll_horizontal_factor=0.35
    pinch_zoom_factor=1.00
    pinch_rotate_factor=1.00
  '';
}
