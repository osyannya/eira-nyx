{ config, lib, ... }:

let
  cfg = config.eira.home.desktop.misc.xdg;

  hasImpermanence = config.options.eira.home.security.impermanence.enable or null != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
in {
  options.eira.home.desktop.misc.xdg = {
    enable = lib.mkEnableOption "XDG settings";
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      autostart.enable = true;
      
      userDirs = {
        enable = true;
        createDirectories = true;
      };

      mimeApps = {
        enable = true;
      };
    };

    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Public"
        "Templates"
        "Videos"
      ];
    };
  };
}
