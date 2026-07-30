{ inputs, pkgs, ... }:

let
  agentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  t3code = pkgs.nixpkgsUnstable.t3code.override {
    enableClaude = true;
    claude-code = agentPackages.claude-code;

    enableCodex = true;
    codex = agentPackages.codex;

    enableOpencode = true;
    opencode = agentPackages.opencode;
  };
in
{
  home-manager.users.anthony.home.packages = [
    # T3 Code's provider health checks and non-Nix distributions (such as the
    # nightly AppImage) resolve these tools from the user's PATH.
    agentPackages.claude-code
    agentPackages.opencode
    pkgs.nixpkgsUnstable.github-cli
    t3code
  ];
}
