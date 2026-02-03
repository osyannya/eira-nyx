{ config, lib, pkgs, ... }:

{
  programs.joplin-desktop = {
    enable = true;
    package = pkgs.joplin-desktop;
  };
}
