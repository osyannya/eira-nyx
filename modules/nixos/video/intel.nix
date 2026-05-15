{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.video.intel;
in {
  options.eira.system.video.intel = {
    enable = lib.mkEnableOption "Intel graphics, media drivers, and VAAPI";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
      ];
    };
  };
}
