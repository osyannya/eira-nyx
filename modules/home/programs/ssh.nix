{ config, lib, ... }:

let
  cfg = config.eira.home.programs.ssh;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
in {
  options.eira.home.programs.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
    };

    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ ".ssh" ];
    };
  };
}
