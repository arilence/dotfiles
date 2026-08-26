{ inputs, pkgs, ... }:

let
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home-manager.users.anthony.home.packages = [
    agentPackages.amp
    agentPackages.claude-code
    agentPackages.codex
    agentPackages.fx
    agentPackages.opencode
    agentPackages.pi
    pkgs.nixosUnstable.github-cli
  ];
}
