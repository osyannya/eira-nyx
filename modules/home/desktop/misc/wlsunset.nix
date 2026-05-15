{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.misc.wlsunset;
in {
  options.eira.home.desktop.misc.wlsunset = {
    enable = lib.mkEnableOption "Wlsunset screen temperature manager";
  };

  config = lib.mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      package = pkgs.wlsunset;
      sunrise = "08:00";
      sunset = "20:00";
    };
  };
}
