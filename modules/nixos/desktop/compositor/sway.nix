{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.desktop.compositor.sway;
in {
  options.eira.system.desktop.compositor.sway = {
    enable = lib.mkEnableOption "Sway Wayland compositor and portals";
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
