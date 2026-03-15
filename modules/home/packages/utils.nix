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
    kdePackages.qt6ct
    slurp
    swaybg
    wmenu
  ];
}
