{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    yq-go
    unzip
  ];

  # for dynamically linked libraries
  programs.nix-ld.enable = true;

  home-manager.users.anthony.programs.mise = {
    enable = true;
    package = inputs.mise.packages.x86_64-linux.mise;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
      };
    };
  };
}
