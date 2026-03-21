{ config, lib, pkgs, ... }:

let
  wallpaper-switch = pkgs.writeShellScriptBin "wallpaper-switch" ''
    set -euo pipefail

    WALLPAPER_DIR="$HOME/Pictures/wallpapers/desktop"
    FALLBACK_COLOR="#ff00ff"
    CURRENT_FILE="/tmp/current-sway-wallpaper"

    # Wait for Wayland startup
    for _ in {1..20}; do
      [[ -n "''${WAYLAND_DISPLAY:-}" ]] && break
      ${pkgs.coreutils}/bin/sleep 0.5
    done

    # Kill existing swaybg
    ${pkgs.procps}/bin/pkill swaybg 2>/dev/null || true
    ${pkgs.coreutils}/bin/sleep 0.1

    # Get all supported images
    shopt -s nullglob
    images=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG})
    shopt -u nullglob

    apply_wallpaper() {
      local target="$1"
      [[ -z "$target" ]] && return 1

      ${pkgs.procps}/bin/pkill swaybg || true
      ${pkgs.coreutils}/bin/sleep 0.05

      if [[ -f "$target" ]]; then
        ${pkgs.swaybg}/bin/swaybg -i "$target" -m fill &
        printf '%s\n' "$target" > "$CURRENT_FILE"
        ${pkgs.libnotify}/bin/notify-send "Wallpaper" "Set: ''${target##*/}"
      else
        ${pkgs.swaybg}/bin/swaybg -c "$FALLBACK_COLOR" &
        ${pkgs.coreutils}/bin/rm -f "$CURRENT_FILE"
        ${pkgs.libnotify}/bin/notify-send "Wallpaper" "Using fallback color"
      fi
    }

    choose_wallpaper() {
      [[ ''${#images[@]} -eq 0 ]] && echo "$FALLBACK_COLOR" && return

      if [[ -f "$CURRENT_FILE" ]]; then
        CURRENT="$(<"$CURRENT_FILE")"
      else
        CURRENT=""
      fi

      case "$1" in
        "next")
          for i in "''${!images[@]}"; do
            [[ "''${images[$i]}" == "$CURRENT" ]] && {
              idx=$(( (i + 1) % ''${#images[@]} ))
              echo "''${images[$idx]}"
              return
            }
          done
          echo "''${images[0]}"
          ;;
        "prev")
          for i in "''${!images[@]}"; do
            [[ "''${images[$i]}" == "$CURRENT" ]] && {
              idx=$(( (i - 1 + ''${#images[@]}) % ''${#images[@]} ))
              echo "''${images[$idx]}"
              return
            }
          done
          echo "''${images[-1]}"
          ;;
        "random")
          printf '%s\n' "''${images[@]}" | ${pkgs.coreutils}/bin/shuf -n1
          ;;
        *)
          printf '%s\n' "''${images[@]##*/}" | \
            ${pkgs.wmenu}/bin/wmenu \
              -f "JetbrainsMono Nerd Font 16" \
              -l 4 \
              -p "Wallpaper:" \
              -N "#1a1b26" \
              -n "#c0caf5" \
              -M "#bb9af7" \
              -m "#1a1b26" \
              -S "#414868" \
              -s "#c0caf5" | \
            while IFS= read -r choice; do
              [[ -n "$choice" ]] && printf '%s/%s\n' "$WALLPAPER_DIR" "$choice"
            done
          ;;
      esac
    }

    if [[ ''${#images[@]} -eq 0 ]]; then
      ${pkgs.libnotify}/bin/notify-send -u low "Wallpaper" "No images in $WALLPAPER_DIR. Using solid color."
      apply_wallpaper "$FALLBACK_COLOR"
      exit 0
    fi

    case "''${1:-}" in
      "next"|"prev"|"random"|"")
        TARGET="$(choose_wallpaper "''${1:-}")"
        ;;
      *)
        if [[ -f "$1" ]]; then
          TARGET="$1"
        else
          ${pkgs.libnotify}/bin/notify-send -u critical "Wallpaper" "File not found: $1"
          exit 1
        fi
        ;;
    esac

    if [[ -z "$TARGET" ]]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "Wallpaper" "No selection made."
      exit 1
    fi

    apply_wallpaper "$TARGET"
  '';
in
{
  home.packages = [ wallpaper-switch ];
}
