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

IFACE=$(detect_wifi_interface)
SSID="$1"
PASS="$2"

# Add network
netid=$(wpa_cli -i "$IFACE" add_network)
wpa_cli -i "$IFACE" set_network "$netid" ssid "\"$SSID\""
wpa_cli -i "$IFACE" set_network "$netid" psk "\"$PASS\""
wpa_cli -i "$IFACE" enable_network "$netid" >/dev/null
wpa_cli -i "$IFACE" select_network "$netid" >/dev/null

echo "Connecting to $SSID..."
for i in {1..15}; do
  sleep 1
  if wpa_cli -i "$IFACE" status | grep -q '^wpa_state=COMPLETED'; then
    notify-send "Wi-Fi" "Connected to $SSID"
    exit 0
  fi
done

notify-send -u critical "Wi-Fi" "Failed to connect to $SSID"
exit 1
