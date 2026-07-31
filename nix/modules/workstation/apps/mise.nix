{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yq-go
    unzip
  ];

  home-manager.users.anthony.programs.mise = {
    enable = true;
    package = pkgs.nixosUnstable.mise;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
      };
    };
  };
}
