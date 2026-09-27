{ lib, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
      default-address-pools = [
        {
          base = "172.17.0.0/12";
          size = 20;
        }
      ];
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  users.users.anthony.extraGroups = [ "docker" ];

  # Disable Docker from starting on boot.
  systemd.services.docker.wantedBy = lib.mkForce [ ];
  systemd.sockets.docker.wantedBy = lib.mkForce [ ];
}
