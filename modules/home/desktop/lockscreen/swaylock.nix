{ config, lib, pkgs, ... }:

let 
  cfg = config.eira.home.desktop.lockscreen.swaylock;
in {
  options.eira.home.desktop.lockscreen.swaylock = {
    enable = lib.mkEnableOption "Swaylock screen locker";
  };

  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock;
      settings = {
        show-failed-attempts = true;
      };
    };
  };
}
