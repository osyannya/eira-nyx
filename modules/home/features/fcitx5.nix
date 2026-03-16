{ config, lib, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = { 
      waylandFrontend = true;
      addons = with pkgs; [ 
        fcitx5-mozc 
        kdePackages.fcitx5-configtool
        fcitx5-gtk 
        kdePackages.fcitx5-qt 
      ];
      # settings.inputMethod = {
        # GroupOrder."0" = "Default";
        # "Groups/0" = {
          # Name = "Default";
          # "Default Layout" = "us";
          # DefaultIM = "mozc";
        # };
        # "Groups/0/Items/0".Name = "keyboard-us";
        # "Groups/0/Items/1".Name = "mozc";
      };
    };
  };
}
