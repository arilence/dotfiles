{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yq-go
    unzip
  ];

  home-manager.users.anthony.programs.mise = {
    enable = true;
    package = pkgs.nixpkgsUnstable.mise;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
      };
    };
  };
}
