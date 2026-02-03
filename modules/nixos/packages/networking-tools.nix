{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    iproute2
    openvpn
    protonvpn-gui
    wget
  ];
}
