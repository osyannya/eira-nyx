{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.communication;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
in {
  options.eira.home.programs.communication = {
    signal.enable = lib.mkEnableOption "Signal desktop messenger";
  };

  config = lib.mkIf cfg.signal.enable {
    home.packages = [ pkgs.signal-desktop ];
    
    home.persistence."/persist" = lib.mkIf persistEnabled {
      directories = [ ".config/Signal" ];
    };
  };
}
