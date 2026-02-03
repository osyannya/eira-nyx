{ config, lib, pkgs, ... }:

{
  # WM/Compositor
  programs.sway = {
    enable = true;
  };

  # xdg-desktop-portal implementation
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Variables
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_QPA_PLATFORM = "wayland";
  };
}
