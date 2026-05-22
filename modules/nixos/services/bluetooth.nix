{ config, lib, ... }:

let
  cfg = config.eira.system.services.bluetooth;

  hasImpermanence = (config.options.eira.system.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.system.security.impermanence.enable;
in {
  options.eira.system.services.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth daemon";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    # Safe persistence mapping
    environment.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ "/var/lib/bluetooth" ];
    };
  };
}
