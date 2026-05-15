{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.creativity;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
in {
  options.eira.home.programs.creativity = {
    gimp.enable = lib.mkEnableOption "GIMP image editor";
  };

  config = lib.mkIf cfg.gimp.enable {
    home.packages = [ pkgs.gimp3 ];
    
    home.persistence."/persist" = lib.mkIf persistEnabled {
      directories = [ ".config/GIMP" ];
    };
  };
}
