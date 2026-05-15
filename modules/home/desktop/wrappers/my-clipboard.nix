{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.wrappers.my-clipboard;

  useStylix = config.stylix.enable or false;

  menuFont = if useStylix then "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.applications}" else "JetbrainsMono Nerd Font 16";
  colBg = if useStylix then config.lib.stylix.colors.base00 else "0f0f0f";
  colFg = if useStylix then config.lib.stylix.colors.base05 else "e5e5e5";
  colSelBg = if useStylix then config.lib.stylix.colors.base0D else "0087ff";
  colSelFg = if useStylix then config.lib.stylix.colors.base00 else "0f0f0f";
  colMatch = if useStylix then config.lib.stylix.colors.base0E else "af5fd7";
  
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
      -f "${menuFont}" \
      -l 4 \
      -p "History:" \
      -N "#${colBg}" \
      -n "#${colFg}" \
      -M "#${colSelBg}" \
      -m "#${colSelFg}" \
      -S "#${colMatch}" \
      -s "#${colFg}" \
    | ${pkgs.cliphist}/bin/cliphist decode \
    | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in {
  options.eira.home.desktop.wrappers.my-clipboard = {
    enable = lib.mkEnableOption "Custom clipboard history script using cliphist and wmenu";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ my-clipboard ];
  };
}
