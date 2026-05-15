{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.wrappers.swaylock-wrapper;

  swaylock-wrapper = pkgs.writeShellScriptBin "swaylock-wrapper" ''
    set -euo pipefail

    LOCK_WALLPAPER_DIR="$HOME/Pictures/wallpapers/lockscreen"
    FALLBACK_COLOR="ffffff"

    # Prevent multiple instances
    if ${pkgs.procps}/bin/pgrep -x swaylock >/dev/null; then
      exit 0
    fi

    shopt -s nullglob nocaseglob
    images=("$LOCK_WALLPAPER_DIR"/*.{jpg,jpeg,png})
    shopt -u nullglob nocaseglob

    if [ "''${#images[@]}" -gt 0 ]; then
      bg_image="$(printf '%s\n' "''${images[@]}" | ${pkgs.coreutils}/bin/shuf -n1)"
      exec ${pkgs.swaylock}/bin/swaylock -f -i "$bg_image"
    else
      exec ${pkgs.swaylock}/bin/swaylock -f -c "$FALLBACK_COLOR"
    fi
  '';
in {
  options.eira.home.desktop.wrappers.swaylock-wrapper = {
    enable = lib.mkEnableOption "Custom swaylock script";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ swaylock-wrapper ];
  };
}

# shopt is a bash builtin maybe should be replaced with the find command
