{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    duf
    file
    # ncdu
    p7zip
    # rclone
    rsync
    tree
    unzip
    zip
  ];
}
