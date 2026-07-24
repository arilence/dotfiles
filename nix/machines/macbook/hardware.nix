{
  config,
  lib,
  ...
}:

{
  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
      "uas"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
    initrd.kernelModules = [ "dm-snapshot" ];

    # MacBookPro11,1 uses a Broadcom BCM4360 wireless adapter. The proprietary
    # wl driver is required for reliable support.
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    blacklistedKernelModules = [
      "b43"
      "bcma"
      "brcmsmac"
      "ssb"
    ];

    extraModprobeConfig = ''
      options hid_apple iso_layout=0
    '';
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
  };

  services = {
    libinput.enable = true;
    thermald.enable = true;
  };
}
