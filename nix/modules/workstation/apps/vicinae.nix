{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  # Add GNOME specific keybinds when GNOME is enabled
  programs.dconf.profiles.user.databases = lib.mkIf config.services.desktopManager.gnome.enable [
    {
      lockAll = true;
      settings = {
        "org/gnome/shell/keybindings" = {
          toggle-overview = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae" = {
          name = "Toggle Vicinae";
          command = "${pkgs.vicinae}/bin/vicinae toggle";
          binding = "<${config.arilence.workstation.keybindings.primaryModifier}>space";
        };
      };
    }
  ];

  home-manager.users.anthony =
    { ... }:
    {
      programs.vicinae = {
        enable = true;
        settings = {
          theme.dark.name = "vicinae-light";
          launcher_window = {
            client_side_decorations.enabled = true;
            compact_mode.enabled = true;
          };
          # Launch applications as transient user services instead of inheriting Vicinae's
          # environment. i.e. before this change, opening any terminal emulator through Vicinae
          # would end up putting `node` (and who know's what other tools) into the PATH.
          providers.applications.preferences.launchPrefix = lib.concatStringsSep " " [
            "${pkgs.systemd}/bin/systemd-run"
            "--user"
            "--collect"
            "--service-type=exec"
            "--same-dir"
            "--expand-environment=no"
            "--"
          ];
        };
        extensions = [
          inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.nix
          inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}.timer
          # Add Raycast extensions with:
          # config.lib.vicinae.mkRayCastExtension
        ];
        systemd = {
          enable = true;
          autoStart = true;
        };
      };

      # Replace the existing imperative settings file with Home Manager's version.
      xdg.configFile."vicinae/settings.json".force = true;
    };
}
