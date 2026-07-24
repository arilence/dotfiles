{ lib, ... }:

{
  arilence.storage.systemDisk = lib.mkDefault "/dev/disk/by-id/nvme-WDS500G3X0C-00SJG0_21045B800563";

  disko.devices.disk.storage = {
    type = "disk";
    device = lib.mkDefault "/dev/disk/by-id/ata-Samsung_SSD_850_PRO_512GB_S39FNX0J804183J";
    content = {
      type = "gpt";
      partitions.luks = {
        size = "100%";
        content = {
          type = "luks";
          name = "crypted-storage";
          passwordFile = "/tmp/luks-passphrase";
          settings.allowDiscards = true;
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes."@storage" = {
              mountpoint = "/storage";
              mountOptions = [
                "compress=zstd"
                "noatime"
                "nofail"
                "x-gvfs-show"
              ];
            };
          };
        };
      };
    };
  };
}
