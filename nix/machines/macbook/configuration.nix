{ lib, ... }:

{
  imports = [
    ../../modules/workstation
    ./hardware.nix
  ];

  arilence.storage.systemDisk = lib.mkDefault "/dev/sda";

  powerManagement.cpuFreqGovernor = "schedutil";

  networking.hostName = "macbook";
  # The BCM4360 requires the unmaintained proprietary wl driver. Keep this
  # exception host-local and version-specific so an update requires review.
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18.36"
  ];
  sops.defaultSopsFile = ./secrets.sops.yaml;

  system.stateVersion = "26.05";
}
