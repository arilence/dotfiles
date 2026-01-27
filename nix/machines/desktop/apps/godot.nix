{ pkgs, ... }:

{
  # This assumes using godot through steam rather than installing it here.

  # for dynamically linked libraries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    fontconfig
  ];
}
