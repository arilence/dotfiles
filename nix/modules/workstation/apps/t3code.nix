{ inputs, pkgs, ... }:

let
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  t3code = pkgs.nixpkgsUnstable.t3code.override {
    enableCodex = true;
    codex = agentPackages.codex;

    enableOpencode = true;
    opencode = agentPackages.opencode;
  };
in
{
  home-manager.users.anthony.home.packages = [
    t3code
  ];
}
