{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.clipboard.cliphist;
in {
  options.eira.home.desktop.clipboard.cliphist = {
    enable = lib.mkEnableOption "Clipboard manager for Wayland";
  };

  config = lib.mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      package = pkgs.cliphist;
      allowImages = true;
      clipboardPackage = pkgs.wl-clipboard;
      extraOptions = [
        "-max-dedupe-search" "10"
        "-max-items" "500"
      ];
      systemdTargets = [ "graphical-session.target" ];
    };
  };
}
