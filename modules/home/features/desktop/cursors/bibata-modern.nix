{ config, lib, pkgs, ... }:

{
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    size = 24;
    package = pkgs.bibata-cursors;
    x11 = {
      enable = true;
      defaultCursor = "Bibata-Modern-Classic";
    };
  };
}
