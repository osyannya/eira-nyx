{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # virtual tpm 2.0 support
    };

    allowedBridges = [ "virbr0" ];
  };
}
