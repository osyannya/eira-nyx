{ config, lib, pkgs, ... }:

{
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    iconTheme.name = "Papirus-Dark";
    cursorTheme.name = "Bibata-Modern-Classic";
    cursorTheme.size = 24;
  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "adwaita-dark";
  };
}
