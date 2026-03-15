{ config, lib, pkgs, ... }:

let
  temporary-wifi = pkgs.writeShellScriptBin "temporary-wifi" ''
    set -euo pipefail

    detect_wifi_interface() {
      local iface
      iface=$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' | ${pkgs.gnugrep}/bin/grep -E '^wl' | head -n1)

      if [[ -n "$iface" ]]; then
        echo "$iface"
        return 0
      fi

      for dev in /sys/class/net/*; do
        if [[ -d "$dev/wireless" ]]; then
          ${pkgs.coreutils}/bin/basename "$dev"
          return 0
        fi
      done

      return 1
    }

    IFACE=$(detect_wifi_interface)
    SSID="$1"
    PASS="$2"

    netid=$(${pkgs.wpa_supplicant}/bin/wpa_cli -i "$IFACE" add_network)
    ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$IFACE" set_network "$netid" ssid "\"$SSID\""
    ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$IFACE" set_network "$netid" psk "\"$PASS\""
    ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$IFACE" enable_network "$netid" >/dev/null
    ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$IFACE" select_network "$netid" >/dev/null

    for i in {1..15}; do
      ${pkgs.coreutils}/bin/sleep 1
      if ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$IFACE" status | ${pkgs.gnugrep}/bin/grep -q '^wpa_state=COMPLETED'; then
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connected to $SSID"
        exit 0
      fi
    done

    ${pkgs.libnotify}/bin/notify-send -u critical "Wi-Fi" "Failed to connect to $SSID"
    exit 1
  '';
in
{
  home.packages = [ temporary-wifi ];
}
