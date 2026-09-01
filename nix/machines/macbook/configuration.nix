{ lib, ... }:

{
  imports = [
    ../../modules/workstation
    ./hardware.nix
  ];

  arilence.storage.systemDisk = lib.mkDefault "/dev/sda";
  arilence.workstation.keybindings.primaryModifier = "Super";

  powerManagement.cpuFreqGovernor = "schedutil";

  # Let Niri and Noctalia handle lid-close locking and suspension without racing systemd-logind's
  # built-in suspend action.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  networking.hostName = "anthony-macbook";

  # The BCM4360 requires the unmaintained proprietary wl driver. Keep this
  # exception host-local, but allow its kernel-coupled version to change.
  nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";
  sops.defaultSopsFile = ./secrets.sops.yaml;

  system.stateVersion = "26.05";
}
