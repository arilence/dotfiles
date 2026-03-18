{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.lutris
  ];

  # for dynamically linked libraries
  programs.nix-ld.enable = true;
}
