{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.browsers;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
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
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".config/BraveSoftware" ];
      };
    })

    (lib.mkIf cfg.firefox.enable {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
      };
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".mozilla" ];
      };
    })

    (lib.mkIf cfg.librewolf.enable {
      programs.librewolf = {
        enable = true;
        package = pkgs.librewolf;
      };
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".librewolf" ];
      };

      xdg.mimeApps.defaultApplications = lib.mkIf (config.xdg.mimeApps.enable or false) {
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
  ];
}
