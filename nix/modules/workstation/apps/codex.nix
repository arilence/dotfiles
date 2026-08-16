{ inputs, pkgs, ... }:

let
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home-manager.users.anthony.home.packages = [
    agentPackages.chatgpt # desktop app
    agentPackages.codex # cli app
  ];
}
