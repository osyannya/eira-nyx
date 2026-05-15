{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.desktop.materials;
in {
  options.eira.system.desktop.materials = {
    enable = lib.mkEnableOption "System-wide icons and cursors";
  };

  config = lib.mkIf cfg.enable {
    gtk.iconCache.enable = true;
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      gsettings-desktop-schemas
    ];
  };
}
