{ config, lib, pkgs, ... }:

{
  # Themes
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    adwaita-qt6
    bibata-cursors
    gnome-themes-extra
    gsettings-desktop-schemas
    papirus-icon-theme
  ];
}
