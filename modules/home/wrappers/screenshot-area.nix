{ config, lib, pkgs, ... }:

let
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    set -euo pipefail

    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
    | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
  '';
in
{
  home.packages = [ screenshot-area ];
}
