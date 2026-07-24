{
  imports = [
    ./gamemode.nix
    ./heroic.nix
    ./moonlight.nix
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  programs.gamescope.enable = true;
}
