{ config, lib, pkgs, ... }:

{
  gtk.iconCache.enable = true;

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };
}
