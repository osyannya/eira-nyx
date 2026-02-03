{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd = { 
    enable = true;
  };

  # virtualisation.vmware.host.enable = true;

  # virtualisation.virtualbox.host = {
  #  enable = true;
  #  enableExtensionPack = true;
  # };

  # virtualisation.waydroid.enable = true;
}
