{ config, lib, pkgs, ... }:

{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G"
          "mode=755"
        ];
      };
    };
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "boot";
              size = "1G";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              name = "root";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                  crypttabExtraOpts = [
                    "tpm2-device=auto"
                    "tpm2-pcrs=7"
                  ];
                };
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--key-size 512"
                  "--hash sha256"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" "-L pool" ];
                  subvolumes = {
                    # "@" = {
                      # mountpoint = "/";
                      # mountOptions = [ "compress=zstd" "noatime" ];
                    # };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "@persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "@swap" = {
                      mountpoint = "/.swap";
                      mountOptions = [ "noatime" "nodatacow" ];
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
