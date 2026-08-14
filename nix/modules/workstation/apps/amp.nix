{ inputs, pkgs, ... }:

let
  ampCli = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.amp;
in
{
  home-manager.users.anthony.home.packages = [
    ampCli
  ];
}
