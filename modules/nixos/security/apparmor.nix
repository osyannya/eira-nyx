{ config, lib, ... }:

let
  cfg = config.eira.system.security.apparmor;
in {
  options.eira.system.security.apparmor = {
    enable = lib.mkEnableOption "AppArmor module";
  };

  config = lib.mkIf cfg.enable {
    security.apparmor = {
      enable = true;
    };
  };
}
