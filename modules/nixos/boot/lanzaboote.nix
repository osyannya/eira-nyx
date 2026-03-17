{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    autoGenerateKeys.enable = true;
    pkiBundle = "/persist/var/lib/sbctl";
    autoEnrollKeys.enable = true; # manual reboot
    configurationLimit = 12;
  };
}

# Generate keys - sudo sbctl create-keys
# Verify - sudo sbctl verify
