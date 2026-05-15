{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.vscode;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
in {
  options.eira.home.programs.vscode = {
    enable = lib.mkEnableOption "VSCodium editor";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
    
    home.persistence."/persist" = lib.mkIf persistEnabled {
      directories = [ ".config/VSCodium" ];
    };
  };
}
