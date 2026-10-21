{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda"; # placeholder, we'll set the stable by-id path once the Pi sees the T5
    content = {
      type = "gpt";
      partitions = {
        firmware = {
          size = "1G";
          type = "0700";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        data = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/mnt/data";
          };
        };
      };
    };
  };
}
