{ config, lib, pkgs, ... }:

let
  firewall-switch = pkgs.writeShellScriptBin "firewall-switch" ''
    set -euo pipefail

    ACTION="''${1:-}"

    # Helper for desktop notifications and stdout
    notify() {
      local urgency="$1"
      local msg="$2"
      echo "[firewall-switch] $msg"
      ${pkgs.libnotify}/bin/notify-send -u "$urgency" "Firewall" "$msg" 2>/dev/null || true
    }

    apply_off() {
      notify "normal" "Disabling firewall (ALLOW ALL)..."
      # Flush existing rules and inject an open policy
      sudo ${pkgs.nftables}/bin/nft -f - <<EOF
flush ruleset
table inet filter {
    chain input { type filter hook input priority 0; policy accept; }
    chain forward { type filter hook forward priority 0; policy accept; }
    chain output { type filter hook output priority 0; policy accept; }
}
EOF
    }

    apply_on() {
      notify "critical" "Blocking all traffic (DROP ALL)..."
      # Flush existing rules and inject a completely closed policy
      sudo ${pkgs.nftables}/bin/nft -f - <<EOF
flush ruleset
table inet filter {
    chain input { type filter hook input priority 0; policy drop; iif "lo" accept; }
    chain forward { type filter hook forward priority 0; policy drop; }
    chain output { type filter hook output priority 0; policy drop; oif "lo" accept; }
}
EOF
    }

    apply_default() {
      notify "normal" "Restoring default NixOS ruleset..."
      # Reload rules
      sudo ${pkgs.systemd}/bin/systemctl restart nftables.service
    }

    case "$ACTION" in
      "off")
        apply_off
        ;;
      "on")
        apply_on
        ;;
      "default")
        apply_default
        ;;
      *)
        echo "Usage: firewall-switch <off|on|default>"
        echo "  off     - Completely disables nftables rules (ALLOW ALL)"
        echo "  on      - Blocks everything (DROP ALL)"
        echo "  default - Returns to default settings declared in NixOS configuration"
        exit 1
        ;;
    esac
  '';
in
{
  home.packages = [ firewall-switch ];
}
