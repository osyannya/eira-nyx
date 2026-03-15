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
    platformTheme.name = "qtct";
    # style.name = "adwaita-dark";
  };
}
