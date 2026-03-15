{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # cloud-hypervisor
    exiftool
    # firecracker
    hexedit
    openssh
    openssl
    qemu
  ];
}
