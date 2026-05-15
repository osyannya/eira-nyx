{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.misc.fcitx5;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
in {
  options.eira.home.desktop.misc.fcitx5 = {
    enable = lib.mkEnableOption "Fcitx5 Wayland input method";
  };

  config = lib.mkIf cfg.enable {
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
      };
    };

    home.persistence."/persist" = lib.mkIf persistEnabled {
      directories = [
        ".config/fcitx"
        ".config/fcitx5"
        ".config/mozc"
      ];
    };
  };
}
