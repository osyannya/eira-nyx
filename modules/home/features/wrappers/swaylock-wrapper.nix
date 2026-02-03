{ config, lib, pkgs, ... }:

let
  swaylock-wrapper = pkgs.writeShellScriptBin "swaylock-wrapper" ''
    set -euo pipefail

    LOCK_WALLPAPER_DIR="$HOME/Pictures/wallpapers/lockscreen"
    FALLBACK_COLOR="ffffff"

    pgrep -x swaylock >/dev/null && exit 0

    shopt -s nullglob nocaseglob
    images=("$LOCK_WALLPAPER_DIR"/*.{jpg,jpeg,png})
    shopt -u nullglob nocaseglob

    if [ "''${#images[@]}" -gt 0 ]; then
      bg_image="$(printf '%s\n' "''${images[@]}" | ${pkgs.coreutils}/bin/shuf -n1)"
      exec ${pkgs.swaylock}/bin/swaylock -i "$bg_image"
    else
      exec ${pkgs.swaylock}/bin/swaylock -c "$FALLBACK_COLOR"
    fi
  '';
in
{
  home.packages = [ swaylock-wrapper ];
}
