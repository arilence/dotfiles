{ config, pkgs, ... }:

{
  sops.secrets.pia-credentials = { };

  services.pia = {
    enable = true;
    credentials.credentialsFile = config.sops.secrets.pia-credentials.path;
    protocol = "wireguard";
    autoConnect = {
      enable = false;
    };
    portForwarding.enable = false;
    dns.enable = true;
  };
}
