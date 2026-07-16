{
  networking.networkmanager.ensureProfiles.profiles.vmbr0 = {
    connection = {
      id = "vmbr0";
      type = "bridge";
      interface-name = "vmbr0";
      autoconnect = "true";
    };

    ipv4 = {
      method = "manual";
      address1 = "10.77.0.1/24";
      never-default = "true";
    };

    ipv6.method = "disabled";
    bridge.stp = "false";
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "vmbr0" ];
    externalInterface = "eno1";
  };

  virtualisation.libvirtd.allowedBridges = [ "vmbr0" ];
}
