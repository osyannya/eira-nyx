{ config, lib, ... }:

{
  boot = {
    # Use the systemd-boot EFI boot loader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
  };
}

# Authentication support, boot loaders: grub, limine
# Secure boot support: lanzaboote
# UEFI password
