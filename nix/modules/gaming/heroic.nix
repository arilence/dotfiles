{
  config,
  pkgs,
  ...
}:

{
  assertions = [
    {
      assertion = config.programs.gamescope.enable;
      message = "Heroic requires programs.gamescope.enable = true;";
    }
    {
      assertion = config.programs.gamemode.enable;
      message = "Heroic requires programs.gamemode.enable = true;";
    }
  ];

  environment.systemPackages = with pkgs; [
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];
}
