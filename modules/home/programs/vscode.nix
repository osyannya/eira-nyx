{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.vscode;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
in {
  options.eira.home.programs.vscode = {
    enable = lib.mkEnableOption "VSCodium editor";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
    
    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ ".config/VSCodium" ];
    };
  };
}
