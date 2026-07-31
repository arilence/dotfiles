{ ... }:

{
  home-manager.users.anthony.programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
