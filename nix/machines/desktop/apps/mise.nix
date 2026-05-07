{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yq-go
    unzip
  ];

  # for dynamically linked libraries
  programs.nix-ld.enable = true;

  home-manager.users.anthony.programs.mise = {
    enable = true;
    package = pkgs.unstable.mise;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
      };
    };
  };
}
