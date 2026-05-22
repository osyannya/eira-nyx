{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.browsers;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;

  hasXdg = (config.options.xdg.mimeApps.enable or null) != null;
  xdgEnabled = hasXdg && config.xdg.mimeApps.enable;
in {
  options.eira.home.programs.browsers = {
    brave.enable = lib.mkEnableOption "Brave browser";
    firefox.enable = lib.mkEnableOption "Firefox browser";
    librewolf.enable = lib.mkEnableOption "Librewolf browser";
    tor.enable = lib.mkEnableOption "Tor browser";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.brave.enable {
      home.packages = [ pkgs.brave ];
    })

    (lib.mkIf cfg.firefox.enable {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
      };
    })

    (lib.mkIf cfg.librewolf.enable {
      programs.librewolf = {
        enable = true;
        package = pkgs.librewolf;
      }; 

      # Set librewolf as the default browser
      xdg.mimeApps.defaultApplications = lib.mkIf xdgEnabled {
        "text/html" = lib.mkDefault ["librewolf.desktop"];
        "x-scheme-handler/http" = lib.mkDefault ["librewolf.desktop"];
        "x-scheme-handler/https" = lib.mkDefault ["librewolf.desktop"];
        "x-scheme-handler/about" = lib.mkDefault ["librewolf.desktop"];
        "x-scheme-handler/unknown" = lib.mkDefault ["librewolf.desktop"];
        "application/x-extension-htm" = lib.mkDefault ["librewolf.desktop"];
        "application/x-extension-html" = lib.mkDefault ["librewolf.desktop"];
        "application/x-extension-shtml" = lib.mkDefault ["librewolf.desktop"];
        "application/x-extension-xht" = lib.mkDefault ["librewolf.desktop"];
        "application/x-extension-xhtml" = lib.mkDefault ["librewolf.desktop"];
        "application/xhtml+xml" = lib.mkDefault ["librewolf.desktop"];
        "application/json" = lib.mkDefault ["librewolf.desktop"];
        "application/pdf" = lib.mkDefault ["librewolf.desktop"];
      };
    })

    (lib.mkIf cfg.tor.enable {
      home.packages = [ pkgs.tor-browser ];
    })

    # Persistent paths
    (lib.mkIf impermanenceEnabled {
      home.persistence."/persist" = {
        directories = 
          (lib.optionals cfg.brave.enable [ ".config/BraveSoftware" ]) ++
          (lib.optionals cfg.firefox.enable [ ".mozilla" ]) ++
          (lib.optionals cfg.librewolf.enable [ ".librewolf" ]);
      };
    })
  ];
}
