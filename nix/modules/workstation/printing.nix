{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.arilence.workstation.printing;
in
{
  options.arilence.workstation.printing.autoDiscovery = lib.mkOption {
    type = lib.types.bool;
    description = "Whether to discover network printers using Avahi and cups-browsed.";
  };

  config = {
    # https://wiki.nixos.org/wiki/Printing#Enable_auto-discovery_of_network_printers
    services.avahi = lib.mkIf cfg.autoDiscovery {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      browsed.enable = cfg.autoDiscovery;
      drivers = lib.optionals cfg.autoDiscovery (
        with pkgs;
        [
          cups-filters
          cups-browsed
        ]
      );
    };
  };
}
