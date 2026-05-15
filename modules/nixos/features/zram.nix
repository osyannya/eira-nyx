{ config, lib, ... }:

let
  cfg = config.eira.system.features.zram;
in {
  options.eira.system.features.zram = {
    enable = lib.mkEnableOption "Zram swap memory management";
  };

  config = lib.mkIf cfg.enable {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };
  };
}
