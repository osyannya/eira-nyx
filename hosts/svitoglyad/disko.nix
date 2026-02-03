{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "umask=0077" ];
              };
            };
            root = {
              end = "-16GiB";
              label = "cryptroot";
              content = {
                type = "luks";
                name = "luksroot";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                # TPM2 unlock configuration
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--key-size 512"
                  "--hash sha256"
                ];
                extraOpenArgs = [ ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" "-L nixos" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "@persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
            swap = {
              size = "16GiB";
              label = "cryptswap";
              content = {
                type = "luks";
                name = "luksswap";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--key-size 512"
                  "--hash sha256"
                ];
                content = {
                  type = "swap";
                  randomEncryption = false;
                  discardPolicy = "both";
                  extraArgs = [ "-L swap" ];
                };
              };
            };
          };
        };
      };
    };
  };
}


