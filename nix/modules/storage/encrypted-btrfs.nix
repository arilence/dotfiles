{
  config,
  lib,
  ...
}:

{
  options.arilence.storage.systemDisk = lib.mkOption {
    type = lib.types.str;
    description = "The block device that Disko will erase and use as the encrypted system disk.";
  };

  config.disko.devices.disk.main = {
    type = "disk";
    device = config.arilence.storage.systemDisk;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          name = "ESP";
          start = "1M";
          end = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            passwordFile = "/tmp/luks-passphrase";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "space_cache=v2"
                  ];
                };

                "@data" = {
                  mountpoint = "/data";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "noatime" ];
                };

                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };

                "@swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "16G";
                  mountOptions = [
                    "noatime"
                    "nodatacow"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
