{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aircrack-ng
    bettercap
    hashcat
    hcxdumptool
    hcxtools
    iw
    macchanger
    mdk4
    netcat-gnu
    nmap
    # recon-ng
    whois
  ];
}
