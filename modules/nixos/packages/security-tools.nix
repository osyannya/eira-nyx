{ config, lib, pkgs, ... }:

{
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.systemPackages = with pkgs; [
    exiftool
    hexedit
    openssh
    openssl
  ];
}
