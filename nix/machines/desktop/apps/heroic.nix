{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];

  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
}
