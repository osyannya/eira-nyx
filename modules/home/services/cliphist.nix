{ config, lib, pkgs, ... }:

{
  services.cliphist = {
    enable = true;
    package = pkgs.cliphist;
    allowImages = true;
    clipboardPackage = pkgs.wl-clipboard;
    extraOptions = [
      "-max-dedupe-search" "10"
      "-max-items" "500"
    ];
    systemdTargets = [ "sway-session.target" ];
  };
}
