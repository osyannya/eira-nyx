{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/persist/var/lib/sbctl";
  };
}

# Generate keys - sudo sbctl create-keys
# Verify - sudo sbctl verify
