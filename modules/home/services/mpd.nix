{ config, lib, pkgs, ... }:

{
  services.mpd = {
    enable = true;
    package = pkgs.mpd;
    # musicDirectory = "${config.home.homeDirectory}/Music";
  };
}
