#!/usr/bin/env bash
set -euo pipefail

# Configuration
SECRETS_FILE="/run/agenix/networks"
TIMEOUT_SECONDS=10

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

if [[ -z "$WIFI_IFACE" ]]; then
    notify-send -u critical "Wi-Fi" "No wireless interface found"
    exit 1
fi

# Helpers
notify() {
    local urgency="${2:-normal}"
    notify-send -u "$urgency" "Wi-Fi" "$1"
}

is_connected() {
    wpa_cli -i "$WIFI_IFACE" status | grep -q '^wpa_state=COMPLETED'
}

get_current_ssid() {
    wpa_cli -i "$WIFI_IFACE" status | awk -F= '/^ssid=/{print $2}'
}

# Checks
# Check wpa_supplicant
if ! pgrep -x wpa_supplicant &>/dev/null; then
    notify "wpa_supplicant is not running" critical
    exit 1
fi

# Check rfkill and unblock soft blocked wlan
if rfkill list wlan | grep -q "Soft blocked: yes"; then
    rfkill unblock wlan
fi

# Check secrets file
if [[ ! -s "$SECRETS_FILE" ]]; then
    notify "No networks found in secrets file: $SECRETS_FILE" critical
    exit 1
fi

# Scan for available SSIDs
wpa_cli -i "$WIFI_IFACE" scan >/dev/null

for _ in $(seq 10); do
    sleep 1
    if [[ $(wpa_cli -i "$WIFI_IFACE" scan_results | tail -n +2 | wc -l) -gt 0 ]]; then
        break
    fi
done

# Read available SSIDs into an array safely (preserve spaces/tabs)
mapfile -t available_ssids < <(
    wpa_cli -i "$WIFI_IFACE" scan_results | tail -n +2 | cut -f5-
)

if [[ ${#available_ssids[@]} -eq 0 ]]; then
    notify "No Wi-Fi networks found nearby" critical
    exit 1
fi

# Read known networks
declare -A networks
while IFS=: read -r ssid psk || [[ -n "$ssid" ]]; do
    [[ -z "$ssid" || -z "$psk" ]] && continue
    networks["$ssid"]="$psk"
done < "$SECRETS_FILE"

# Filter networks by availability
filtered_ssids=()
for ssid in "${available_ssids[@]}"; do
    ssid_trimmed="$(echo -n "$ssid" | xargs)"
    [[ -z "$ssid_trimmed" ]] && continue     # skip empty entries
    if [[ -n "${networks[$ssid_trimmed]+x}" ]]; then
        filtered_ssids+=("$ssid_trimmed")
    fi
done

if [[ ${#filtered_ssids[@]} -eq 0 ]]; then
    notify "No known networks are currently available" critical
    exit 1
fi

# Attempt to connect
for ssid in "${filtered_ssids[@]}"; do
    psk="${networks[$ssid]}"

    netid="$(wpa_cli -i "$WIFI_IFACE" add_network | tr -d '\r')"
    [[ "$netid" =~ ^[0-9]+$ ]] || continue

    wpa_cli -i "$WIFI_IFACE" set_network "$netid" ssid "\"$ssid\"" &>/dev/null

    if [[ "$psk" =~ ^[0-9a-fA-F]{64}$ ]]; then
        wpa_cli -i "$WIFI_IFACE" set_network "$netid" psk "$psk" &>/dev/null
    else
        wpa_cli -i "$WIFI_IFACE" set_network "$netid" psk "\"$psk\"" &>/dev/null
    fi

    wpa_cli -i "$WIFI_IFACE" enable_network "$netid" &>/dev/null
    wpa_cli -i "$WIFI_IFACE" select_network "$netid" &>/dev/null

    for _ in $(seq "$TIMEOUT_SECONDS"); do
        sleep 1
        if is_connected; then
            notify "Connected to: $(get_current_ssid)"
            exit 0
        fi
    done

    wpa_cli -i "$WIFI_IFACE" remove_network "$netid" &>/dev/null
done

notify "Failed to connect to any available known network" critical
exit 2

