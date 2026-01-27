{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yq-go
    unzip
    mise
  ];

  # for dynamically linked libraries
  programs.nix-ld.enable = true;

  home-manager.users.anthony.programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
      };
    };
  };
}
