{ config, lib, ... }:

let
  cfg = config.eira.system.services.power;
in {
  options.eira.system.services.power = {
    enable = lib.mkEnableOption "Unified power management and logind lid-switch behavior";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;

    services.logind.settings.Login = {
      HandleSuspendKey = "hibernate";
      HandleLidSwitch = "suspend";
    };
  };
}
