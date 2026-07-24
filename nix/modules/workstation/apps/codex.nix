{ inputs, pkgs, ... }:

let
  codexCli = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
in
{
  home-manager.users.anthony = {
    imports = [
      inputs.codex-desktop-linux.homeManagerModules.default
    ];

    home.packages = [
      codexCli
    ];

    programs.codexDesktopLinux = {
      enable = true;
      # Bake CODEX_CLI_PATH into the launcher so Codex Desktop can find the CLI
      # when launched from GNOME, not just from a shell with PATH initialized.
      cliPackage = codexCli;
    };
  };
}
