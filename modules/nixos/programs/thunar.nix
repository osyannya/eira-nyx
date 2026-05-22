{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.programs.thunar;
in {
  options.eira.system.programs.thunar = {
    enable = lib.mkEnableOption "Thunar file manager and virtual filesystem daemons";
  };

  config = lib.mkIf cfg.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        tumbler
      ];
    };

    services.gvfs.enable = true; # Recycle bin
    services.tumbler.enable = true; # File preview
    services.udisks2.enable = true; # Auto mounting 
  };
}
