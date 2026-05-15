{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.productivity;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
in {
  options.eira.home.programs.productivity = {
    joplin.enable = lib.mkEnableOption "Joplin desktop";
    keepassxc.enable = lib.mkEnableOption "KeePassXC password manager";
    libreoffice.enable = lib.mkEnableOption "LibreOffice suite";
    qalculate.enable = lib.mkEnableOption "Qalculate calculator";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.joplin.enable {
      programs.joplin-desktop = {
        enable = true;
        package = pkgs.joplin-desktop;
      };
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ 
          ".config/Joplin" 
          ".config/joplin-desktop" 
          "JoplinBackup" 
        ];
      };
    })

    (lib.mkIf cfg.keepassxc.enable {
      programs.keepassxc = {
        enable = true;
        package = pkgs.keepassxc;
        autostart = true;
      };
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".config/keepassxc" ];
      };
    })

    (lib.mkIf cfg.libreoffice.enable {
      home.packages = [ pkgs.libreoffice-qt6-fresh ];
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".config/libreoffice" ];
      };
    })

    (lib.mkIf cfg.qalculate.enable {
      home.packages = [ pkgs.qalculate-gtk ];
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ 
          ".config/qalculate" 
          ".local/share/qalculate" 
        ];
      };
    })
  ];
}
