{ config, lib, pkgs, ... }:

let
  disconnect-wifi = pkgs.writeShellScriptBin "disconnect-wifi" ''
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

    WIFI_IFACE=$(detect_wifi_interface)

    if ! ${pkgs.procps}/bin/pgrep -x wpa_supplicant >/dev/null; then
      ${pkgs.libnotify}/bin/notify-send -u critical "Wi-Fi Error" "wpa_supplicant is not running"
      exit 1
    fi

    current_net=$(${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" list_networks | ${pkgs.gawk}/bin/awk 'NR>1 && $4=="[CURRENT]" {print $1}')

    if [[ -n "$current_net" ]]; then
      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" disable_network "$current_net" >/dev/null
      ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$WIFI_IFACE" remove_network "$current_net" >/dev/null
      ${pkgs.libnotify}/bin/notify-send -u normal "Wi-Fi" "Disconnected from Wi-Fi"
    else
      ${pkgs.libnotify}/bin/notify-send -u normal "Wi-Fi" "Already disconnected"
    fi
  '';
in
{
  home.packages = [ disconnect-wifi ];
}
