{ pkgs, inputs, ... }:

{
  console.keyMap = "us";

  i18n = {
    defaultLocale = "en_CA.UTF-8";
    inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    };
  };

  environment.systemPackages = with pkgs; [
    xkeyboard-config
    libxkbcommon
    zed-editor
  ];
}
