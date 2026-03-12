{ config, lib, pkgs, ... }:

let
  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    set -euo pipefail

    ${pkgs.grim}/bin/grim - \
    | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png 
  '';
in
{
  home.packages = [ screenshot ];
}


