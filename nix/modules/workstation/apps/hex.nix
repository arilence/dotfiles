{
  config,
  inputs,
  pkgs,
  ...
}:

let
  modifier =
    if config.arilence.workstation.keybindings.primaryModifier == "Super" then "super" else "alt";

  # Hex's Oxc dependency needs Rust >= 1.97; keep its native libraries on stable Nixpkgs.
  rustPlatform = pkgs.makeRustPlatform {
    inherit (pkgs.nixosUnstable) cargo rustc;
  };
in
{
  home-manager.users.anthony = {
    imports = [ inputs.hex.homeManagerModules.hex ];
    programs.hex = {
      enable = true;
      package = inputs.hex.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        inherit rustPlatform;
      };
      autostart = true;
      shortcut = "${modifier}+shift+space";
      model = "parakeet_unified_en";
      language = "en";
      installModel = true;
      settings.shortcut_mode = "toggle";
    };
  };
}
