{ config, lib, pkgs, ... }:

let
  my-menu = pkgs.writeShellScriptBin "my-menu" ''
    set -euo pipefail

    # Prevent multiple instances
    if ${pkgs.procps}/bin/pgrep -x wmenu >/dev/null; then
      exit 0
    fi
    if ${pkgs.procps}/bin/pgrep -x wmenu-run >/dev/null; then
      exit 0
    fi

    exec ${pkgs.wmenu}/bin/wmenu-run \
      -f "JetbrainsMono Nerd Font 16" \
      -l 0 \
      -p "Run:" \
      -N "#0f0f0f" \
      -n "#e5e5e5" \
      -M "#0087ff" \
      -m "#0f0f0f" \
      -S "#af5fd7" \
      -s "#ffffff"
  '';
in
{
  home.packages = [ my-menu ];
}

