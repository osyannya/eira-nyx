{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_DRM_NO_ATOMIC = "1";
  };

  environment.variables = {
    WLR_BACKEND = "vulkan";
  };

  hardware.graphics = {
    enable = true;
    # driSupport = true;
    # driSupport32Bit = true; both have no impact
  };

  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
}
