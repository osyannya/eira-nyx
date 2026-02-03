{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    gimp3
    # kdePackages.kdenlive
    libreoffice-qt6-fresh
    qalculate-gtk
    qbittorrent
    signal-desktop
    spotify
    prismlauncher
    tor-browser
    # vlc
  ];
}
