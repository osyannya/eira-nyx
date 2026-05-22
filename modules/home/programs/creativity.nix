{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.creativity;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
in {
  options.eira.home.programs.creativity = {
    gimp.enable = lib.mkEnableOption "GIMP image editor";
  };

  config = lib.mkIf cfg.gimp.enable {
    home.packages = [ pkgs.gimp3 ];
    
    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ ".config/GIMP" ];
    };
  };
}
