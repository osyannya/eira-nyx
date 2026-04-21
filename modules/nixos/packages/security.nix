{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bubblewrap
    cage
    # cloud-hypervisor
    exiftool
    # firecracker
    hexedit
    openssh
    openssl
    qemu_kvm
    veracrypt
  ];
}
