{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    dnsmasq
    iproute2
    openvpn
    protonvpn-gui
    wget
  ];
}
