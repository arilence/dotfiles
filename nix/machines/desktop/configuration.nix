{ config, ... }:

{
  imports = [
    ../../modules/workstation
    ../../modules/development/android.nix
    ../../modules/gaming
    ../../modules/virtualization

    ./disk-config.nix
    ./modules/com-arilence-box-vm-network.nix
    ./modules/networking.nix
    ./modules/nvidia-gpu.nix
  ];

  arilence.workstation.apps.handy.autoStart = true;

  sops.defaultSopsFile = ./secrets.sops.yaml;

  # This workstation should stay awake and available for remote access.
  services.displayManager.gdm.autoSuspend = false;
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  # Better SSD performance. The name must match the shared single-disk
  # layout used by each workstation host.
  boot.initrd.luks.devices."crypted-storage".bypassWorkqueues = true;

  systemd.tmpfiles.rules = [
    # The secondary drive mountpoint is declared in disk-config.nix.
    "d /storage 1777 root root -"
  ];

  # Preserve the compatibility baseline of the existing installation.
  system.stateVersion = "25.11";
}
