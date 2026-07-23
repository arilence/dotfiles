{ pkgs, ... }:

{
  users.users.anthony.extraGroups = [
    "kvm" # hardware virtualization for android emulators
    "adbusers" # android debug bridge (ADB)
  ];
}
