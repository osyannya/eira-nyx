#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/wallpapers/desktop"
FALLBACK_COLOR="#00aaaa"
CURRENT_FILE="/tmp/current-sway-wallpaper"

# Wait for Wayland startup
for _ in {1..20}; do
    [[ -n "${WAYLAND_DISPLAY:-}" ]] && break
    sleep 0.5
done

# Kill existing swaybg
pkill swaybg 2>/dev/null || true
sleep 0.1

# Get all supported images
shopt -s nullglob
images=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG})
shopt -u nullglob

# Apply wallpaper
apply_wallpaper() {
    local target="$1"
    [[ -z "$target" ]] && return 1
    
    # Kill old swaybg
    pkill swaybg || true
    sleep 0.05
    
    if [[ -f "$target" ]]; then
        # Normal image
        swaybg -i "$target" -m fill &
        printf '%s\n' "$target" > "$CURRENT_FILE"
        notify-send "Wallpaper" "Set: ${target##*/}"
    else
        # Solid color fallback
        swaybg -c "$FALLBACK_COLOR" &
        rm -f "$CURRENT_FILE"
        notify-send "Wallpaper" "Using fallback color"
    fi
}

# Choose wallpaper
choose_wallpaper() {
    # If no images - fallback
    [[ ${#images[@]} -eq 0 ]] && echo "$FALLBACK_COLOR" && return
    
    # Read current wallpaper
    if [[ -f "$CURRENT_FILE" ]]; then
        CURRENT="$(<"$CURRENT_FILE")"
    else
        CURRENT=""
    fi
    
    case "$1" in
        "next")
            for i in "${!images[@]}"; do
                [[ "${images[$i]}" == "$CURRENT" ]] && {
                    idx=$(( (i + 1) % ${#images[@]} ))
                    echo "${images[$idx]}"
                    return
                }
            done
            echo "${images[0]}"  # fallback to first
            ;;
        "prev")
            for i in "${!images[@]}"; do
                [[ "${images[$i]}" == "$CURRENT" ]] && {
                    idx=$(( (i - 1 + ${#images[@]}) % ${#images[@]} ))
                    echo "${images[$idx]}"
                    return
                }
            done
            echo "${images[-1]}"  # fallback to last
            ;;
        "random")
            printf '%s\n' "${images[@]}" | shuf -n1
            ;;
        *) # menu
            # Show only filenames
            printf '%s\n' "${images[@]##*/}" | wmenu -f "JetbrainsMono Nerd Font 16" -l 4 -p "Wallpaper:" -N "#1a1b26" -n "#c0caf5" -M "#bb9af7" -m "#1a1b26" -S "#414868" -s "#c0caf5" | \
            while IFS= read -r choice; do
                [[ -n "$choice" ]] && printf '%s/%s\n' "$WALLPAPER_DIR" "$choice"
            done
            ;;
    esac
}

# Main logic
if [[ ${#images[@]} -eq 0 ]]; then
    notify-send -u low "Wallpaper" "No images in $WALLPAPER_DIR. Using solid color."
    apply_wallpaper "$FALLBACK_COLOR"
    exit 0
fi

# Handle arguments
case "${1:-}" in
    "next"|"prev"|"random"|"")
        TARGET="$(choose_wallpaper "${1:-}")"
        ;;
    *)
        # Direct path given
        if [[ -f "$1" ]]; then
            TARGET="$1"
        else
            notify-send -u critical "Wallpaper" "File not found: $1"
            exit 1
        fi
        ;;
esac

if [[ -z "$TARGET" ]]; then
    notify-send -u critical "Wallpaper" "No selection made."
    exit 1
fi

apply_wallpaper "$TARGET"
