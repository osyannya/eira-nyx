{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.wrappers.screenshot;

  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    set -euo pipefail

    ${pkgs.grim}/bin/grim - \
    | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png 
  '';
in {
    options.eira.home.desktop.wrappers.screenshot = {
    enable = lib.mkEnableOption "Custom script for screenshots of fullscreen";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ screenshot ];
  };
}


