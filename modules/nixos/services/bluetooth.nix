{ config, lib, ... }:

let
  cfg = config.eira.system.services.bluetooth;
in {
  options.eira.system.services.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth daemon";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    # Safe persistence mapping
    environment.persistence."/persist" = lib.mkIf (config.eira.system.security.impermanence.enable or false) {
      directories = [
        "/var/lib/bluetooth"
      ];
    };
  };
}
