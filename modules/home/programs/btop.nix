{ config, lib, pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop;
    settings = {
      color_theme = "default";
      theme_background = true;
    };
  };
}
