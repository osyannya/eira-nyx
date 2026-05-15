{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.video.amd;
in {
  options.eira.system.video.amd = {
    enable = lib.mkEnableOption "AMD graphics and open-source Mesa drivers";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    boot.initrd.kernelModules = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd # OpenCL support
      ];
    };
  };
}
