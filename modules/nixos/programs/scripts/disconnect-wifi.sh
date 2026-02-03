#!/usr/bin/env bash
set -euo pipefail

# Auto-detect wireless interface
detect_wifi_interface() {
    # Find first wireless interface that's up
    local iface
    iface=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^wl' | head -n1)
    
    if [[ -n "$iface" ]]; then
        echo "$iface"
        return 0
    fi
    
    # Check /sys/class/net for wireless devices
    for dev in /sys/class/net/*; do
        if [[ -d "$dev/wireless" ]]; then
            basename "$dev"
            return 0
        fi
    done
    
    return 1
}

WIFI_IFACE=$(detect_wifi_interface)

if ! pgrep -x wpa_supplicant >/dev/null; then
  notify-send -u critical "Wi-Fi Error" "wpa_supplicant is not running"
  exit 1
fi

current_net=$(wpa_cli -i "$WIFI_IFACE" list_networks | awk 'NR>1 && $4=="[CURRENT]" {print $1}')
if [[ -n "$current_net" ]]; then
  wpa_cli -i "$WIFI_IFACE" disable_network "$current_net" >/dev/null
  wpa_cli -i "$WIFI_IFACE" remove_network "$current_net" >/dev/null
  notify-send -u normal "Wi-Fi" "Disconnected from Wi-Fi"
else
  notify-send -u normal "Wi-Fi" "Already disconnected"
fi
