{ pkgs, ... }:

{
  users.users.anthony.extraGroups = [
    "kvm" # hardware virtualization for android emulators
    "adbusers" # android debug bridge (ADB)
  ];

  environment.systemPackages = with pkgs; [
    android-studio
  ];

  programs.adb.enable = true;

  # for dynamically linked libraries
  programs.nix-ld.enable = true;
}
