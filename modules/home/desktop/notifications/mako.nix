{ config, lib, pkgs, ... }:

let 
  cfg = config.eira.home.desktop.notifications.mako;
in {
  options.eira.home.desktop.notifications.mako = {
    enable = lib.mkEnableOption "Mako notification daemon";
  };

  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;
      package = pkgs.mako;
      settings = {
        border-size = 2;
        padding = "10";
        margin = "10";
        anchor = "top-right";
        default-timeout = 8000;
      };
    };
  };
}
