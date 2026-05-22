{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.communication;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
in {
  options.eira.home.programs.communication = {
    signal.enable = lib.mkEnableOption "Signal desktop messenger";
  };

  config = lib.mkIf cfg.signal.enable {
    home.packages = [ pkgs.signal-desktop ];
    
    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ ".config/Signal" ];
    };
  };
}
