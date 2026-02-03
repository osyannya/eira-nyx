{ config, lib, pkgs, ... }:

{
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    package = pkgs.wireshark;
    usbmon.enable = false;
  };
}
