{ config, lib, pkgs, ... }:

let
  my-clipboard = pkgs.writeShellScriptBin "my-clipboard" ''
    set -euo pipefail

    # Prevent multiple instances
    if ${pkgs.procps}/bin/pgrep -x wmenu >/dev/null; then
      exit 0
    fi
    if ${pkgs.procps}/bin/pgrep -x wmenu-run >/dev/null; then
      exit 0
    fi

    ${pkgs.cliphist}/bin/cliphist list \
    | ${pkgs.wmenu}/bin/wmenu \
      -f "JetbrainsMono Nerd Font 16" \
      -l 4 \
      -p "History:" \
      -N "#0f0f0f" \
      -n "#e5e5e5" \
      -M "#0087ff" \
      -m "#0f0f0f" \
      -S "#af5fd7" \
      -s "#ffffff" \
    | ${pkgs.cliphist}/bin/cliphist decode \
    | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in {
  home.packages = [ my-clipboard ];
}
