{ config, lib, pkgs, ... }:

let
  disable-wan = pkgs.writeShellScriptBin "disable-wan" ''
    set -euo pipefail

    UPLINK="''${1:?Usage: $0 <uplink>}"
    NS="wanns"
    VETH_HOST="veth-host-wan"
    DNSMASQ_PID="/tmp/wanns-dnsmasq.pid"

    # nft table names — must match enable-nat.sh exactly
    NFT_TABLE_NAT="inet wan-vm-nat"
    NFT_TABLE_FILTER="inet wan-vm-filter"
    NFT_TABLE_HOST="inet wan-vm-host-isolation"

    echo "[disable-wan] Starting teardown..."

    # Kill dnsmasq if it's running
    if [ -f "$DNSMASQ_PID" ]; then
        PID=$(${pkgs.coreutils}/bin/cat "$DNSMASQ_PID")
        echo "[disable-wan] Stopping dnsmasq (PID: $PID)..."
        ${pkgs.coreutils}/bin/kill "$PID" 2>/dev/null || true
        ${pkgs.coreutils}/bin/rm -f "$DNSMASQ_PID"
    fi

    # Remove Host Route
    echo "[disable-wan] Removing host route for 172.31.253.0/24..."
    ${pkgs.iproute2}/bin/ip route delete 172.31.253.0/24 2>/dev/null || true

    # Delete Host Veth interface (this also deletes the peer inside the NS)
    if ${pkgs.iproute2}/bin/ip link show "$VETH_HOST" &>/dev/null; then
        echo "[disable-wan] Deleting host veth interface $VETH_HOST..."
        ${pkgs.iproute2}/bin/ip link delete "$VETH_HOST"
    fi

    # Delete Network Namespace
    if ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^''${NS}\b"; then
        echo "[disable-wan] Deleting network namespace $NS..."
        ${pkgs.iproute2}/bin/ip netns delete "$NS"
    fi

    # Clean up nftables tables
    echo "[disable-wan] Cleaning up nftables rules..."
    ${pkgs.nftables}/bin/nft delete table $NFT_TABLE_NAT 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete table $NFT_TABLE_FILTER 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete table $NFT_TABLE_HOST 2>/dev/null || true

    ${pkgs.nftables}/bin/nft delete rule inet filter input iifname "$VETH_HOST" accept 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete rule inet filter output oifname "$VETH_HOST" accept 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete rule inet filter forward iifname "$VETH_HOST" oifname "$UPLINK" accept 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete rule inet filter forward iifname "$UPLINK" oifname "$VETH_HOST" ct state established,related accept 2>/dev/null || true

    # Cleanup lease files
    ${pkgs.coreutils}/bin/rm -f /tmp/wanns-dnsmasq.leases

    echo "[disable-wan] Teardown complete."
  '';
in
{
  home.packages = [ disable-wan ];
}
