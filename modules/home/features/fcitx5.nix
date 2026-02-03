{ config, lib, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [ 
      fcitx5-mozc 
      kdePackages.fcitx5-configtool
      fcitx5-gtk 
      libsForQt5.fcitx5-qt 
    ];
  };
}
