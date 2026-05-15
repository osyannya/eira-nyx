{ config, lib, ... }:

let
  cfg = config.eira.home.desktop.xdg;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
in {
  options.eira.home.desktop.xdg = {
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

    home.persistence."/persist" = lib.mkIf (persistEnabled && config.xdg.userDirs.enable) {
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
