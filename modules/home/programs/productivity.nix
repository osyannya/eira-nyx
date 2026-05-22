{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.productivity;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
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
    })

    (lib.mkIf cfg.keepassxc.enable {
      programs.keepassxc = {
        enable = true;
        package = pkgs.keepassxc;
        autostart = true;
      };
    })

    (lib.mkIf cfg.libreoffice.enable {
      home.packages = [ pkgs.libreoffice-qt6-fresh ];
    })

    (lib.mkIf cfg.qalculate.enable {
      home.packages = [ pkgs.qalculate-gtk ];
    })

    # Persistent paths
    (lib.mkIf impermanenceEnabled {
      home.persistence."/persist" = {
        directories = 
          (lib.optionals cfg.joplin.enable [ ".config/Joplin" ".config/joplin-desktop" "JoplinBackup"  ]) ++
          (lib.optionals cfg.keepassxc.enable [ ".config/keepassxc" ]) ++
          (lib.optionals cfg.libreoffice.enable [ ".config/libreoffice" ]) ++
          (lib.optionals cfg.qalculate.enable [ ".config/qalculate" ".local/share/qalculate" ]);
      };
    })
  ];
}
