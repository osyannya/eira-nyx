{ config, lib, pkgs, ... }:

{
  # File manager
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      tumbler
    ];
  };

  # Virtual filesystem implementation
  services.gvfs.enable = true;

  # Thumbnail support for images
  services.tumbler.enable = true;

  # Auto mounting connected media
  services.udisks2.enable = true;
}
