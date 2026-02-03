{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    brightnessctl
    grim
    imagemagick
    inxi
    libnotify
    libsForQt5.qt5ct
    pavucontrol
    rivalcfg
    qt6Packages.qt6ct
    slurp
    swaybg
    # wlsunset # available as a service (does not work after resume nvidia)
    wmenu
  ];
}
