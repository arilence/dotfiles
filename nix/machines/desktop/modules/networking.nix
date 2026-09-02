{ config, lib, ... }:

{
  options.arilence.networking.primaryInterface = lib.mkOption {
    type = lib.types.str;
    description = "Primary physical network interface.";
  };

  config = {
    arilence.networking.primaryInterface = "eno1";

    networking = {
      hostName = "anthony-desktop";

      # NetworkManager manages DHCP for the primary interface.
      interfaces.${config.arilence.networking.primaryInterface}.useDHCP = false;
    };
  };
}
