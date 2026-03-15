{ config, lib, pkgs, ... }:

let
  connect-wifi = pkgs.writeShellScriptBin "connect-wifi" ''
    set -euo pipefail

    SECRETS_FILE="/run/agenix/networks"
    TIMEOUT_SECONDS=10

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

    WIFI_IFACE=$(detect_wifi_interface)

    if [[ -z "$WIFI_IFACE" ]]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "Wi-Fi" "No wireless interface found"
      exit 1
    fi

    notify() {
      local urgency="''${2:-normal}"
      ${pkgs.libnotify}/bin/notify-send -u "$urgency" "Wi-Fi" "$1"
    }

    is_connected() {
      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" status | ${pkgs.gnugrep}/bin/grep -q '^wpa_state=COMPLETED'
    }

    get_current_ssid() {
      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" status | ${pkgs.gawk}/bin/awk -F= '/^ssid=/{print $2}'
    }

    if ! ${pkgs.procps}/bin/pgrep -x wpa_supplicant &>/dev/null; then
      notify "wpa_supplicant is not running" critical
      exit 1
    fi

    if ${pkgs.util-linux}/bin/rfkill list wlan | ${pkgs.gnugrep}/bin/grep -q "Soft blocked: yes"; then
      ${pkgs.util-linux}/bin/rfkill unblock wlan
    fi

    if [[ ! -s "$SECRETS_FILE" ]]; then
      notify "No networks found in secrets file: $SECRETS_FILE" critical
      exit 1
    fi

    ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" scan >/dev/null
    for _ in $(${pkgs.coreutils}/bin/seq 10); do
      ${pkgs.coreutils}/bin/sleep 1
      if [[ $(${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" scan_results | tail -n +2 | wc -l) -gt 0 ]]; then
        break
      fi
    done

    mapfile -t available_ssids < <(
      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" scan_results | tail -n +2 | cut -f5-
    )

    if [[ ''${#available_ssids[@]} -eq 0 ]]; then
      notify "No Wi-Fi networks found nearby" critical
      exit 1
    fi

    declare -A networks
    while IFS=: read -r ssid psk || [[ -n "$ssid" ]]; do
      [[ -z "$ssid" || -z "$psk" ]] && continue
      networks["$ssid"]="$psk"
    done < "$SECRETS_FILE"

    filtered_ssids=()
    for ssid in "''${available_ssids[@]}"; do
      ssid_trimmed="$(echo -n "$ssid" | ${pkgs.findutils}/bin/xargs)"
      [[ -z "$ssid_trimmed" ]] && continue
      if [[ -n "''${networks[$ssid_trimmed]+x}" ]]; then
        filtered_ssids+=("$ssid_trimmed")
      fi
    done

    if [[ ''${#filtered_ssids[@]} -eq 0 ]]; then
      notify "No known networks are currently available" critical
      exit 1
    fi

    for ssid in "''${filtered_ssids[@]}"; do
      psk="''${networks[$ssid]}"
      netid="$(${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" add_network | ${pkgs.coreutils}/bin/tr -d '\r')"
      [[ "$netid" =~ ^[0-9]+$ ]] || continue

      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" set_network "$netid" ssid "\"$ssid\"" &>/dev/null

      if [[ "$psk" =~ ^[0-9a-fA-F]{64}$ ]]; then
        ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" set_network "$netid" psk "$psk" &>/dev/null
      else
        ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" set_network "$netid" psk "\"$psk\"" &>/dev/null
      fi

      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" enable_network "$netid" &>/dev/null
      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" select_network "$netid" &>/dev/null

      for _ in $(${pkgs.coreutils}/bin/seq "$TIMEOUT_SECONDS"); do
        ${pkgs.coreutils}/bin/sleep 1
        if is_connected; then
          notify "Connected to: $(get_current_ssid)"
          exit 0
        fi
      done

      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" remove_network "$netid" &>/dev/null
    done

    notify "Failed to connect to any available known network" critical
    exit 2
  '';
in
{
  home.packages = [ connect-wifi ];
}
