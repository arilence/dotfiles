{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./gamemode.nix
    ./heroic.nix
    ./moonlight.nix
  ];

  # Better performance in Wine and Proton applications
  boot.kernelModules = [ "ntsync" ];

  programs.steam = lib.mkMerge [
    {
      enable = true;
      protontricks.enable = true;
    }
    (lib.mkIf config.programs.niri.enable {
      package = pkgs.steam.override {
        extraArgs = "-system-composer";
      };
    })
  ];

  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  # Libratbag and piper are used to modify gaming mouse settings like polling rate and DPI presets.
  # Super handy as an alternative to installing the manufacturers software like Logitech G Hub.
  services.ratbagd.enable = true;
  environment.systemPackages = with pkgs; [
    libratbag
    piper
  ];
}
