{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.wrappers.screenshot-area;

  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    set -euo pipefail

    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
    | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
  '';
in {
  options.eira.home.desktop.wrappers.screenshot-area = {
    enable = lib.mkEnableOption "Custom script for screenshots";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ screenshot-area ];
  };
}
