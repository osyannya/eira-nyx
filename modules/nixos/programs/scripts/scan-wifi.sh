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

sudo iw dev "$IFACE" scan | awk '
BEGIN {
    ssid = "";
    bssid = "";
    freq = "";
    signal = "";
    security = "Open";
    print_header = 1;
}

/^BSS [0-9a-fA-F:]+/ {
    if (bssid != "") {
        if (print_header) {
            printf "%-30s %-20s %-8s %-6s %s\n", "SSID", "BSSID", "SIGNAL", "FREQ", "SECURITY";
            print_header = 0;
        }
        printf "%-30s %-20s %-8s %-6s %s\n", ssid, bssid, signal, freq, security;
    }

    # Reset values for the new BSS
    ssid = "(hidden)";
    freq = "";
    signal = "";
    security = "Open";

    split($2, b, "(");
    bssid = b[1];
    next;
}

/^\s*SSID:/ {
    match($0, /SSID: (.*)/, m);
    if (length(m[1]) > 0) ssid = m[1];
}

/^\s*freq:/ {
    match($0, /freq: ([0-9]+)/, m);
    freq = m[1];
}

/^\s*signal:/ {
    match($0, /signal: (-?[0-9]+\.[0-9]+)/, m);
    signal = m[1];
}

/^\s*RSN:/ {
    security = "WPA2";
}

/^\s*WPA:/ {
    if (security != "WPA2") security = "WPA";
}

/^\s*SAE:/ {
    security = "WPA3";
}

END {
    if (bssid != "") {
        if (print_header) {
            printf "%-30s %-20s %-8s %-6s %s\n", "SSID", "BSSID", "SIGNAL", "FREQ", "SECURITY";
        }
        printf "%-30s %-20s %-8s %-6s %s\n", ssid, bssid, signal, freq, security;
    }
}
'
