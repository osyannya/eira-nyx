{ config, lib, ... }:

let
  cfg = config.eira.system.video.nvidia;
in {
  options.eira.system.video.nvidia = {
    enable = lib.mkEnableOption "Nvidia proprietary drivers, DRM modesetting, and GLX overrides";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
    };

    # environment.sessionVariables = {
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # GBM_BACKEND = "nvidia-drm";
      # LIBVA_DRIVER_NAME = "nvidia";
      # WLR_NO_HARDWARE_CURSORS = "1";
    # };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
  };
}

# Remove variables in favor of multi GPU
