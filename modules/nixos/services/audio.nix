{ config, lib, ... }:

let
  cfg = config.eira.system.services.audio;
in {
  options.eira.system.services.audio = {
    enable = lib.mkEnableOption "Pipewire audio server and realtime scheduling";
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;
  };
}
