{ config, lib, pkgs, ... }:

let
  enable-lab = pkgs.writeShellScriptBin "enable-lab" ''
    set -euo pipefail

    NUM_TAPS="''${1:?Usage: $0 <num_taps>}"
    NS="labns"

    # Air-gapped Subnets
    BR_IP4="10.99.99.1"
    BR_CIDR4="10.99.99.1/24"
    DHCP4_START="10.99.99.10"
    DHCP4_END="10.99.99.250"

    BR_IP6="fd00:dead:beef::1"
    BR_CIDR6="fd00:dead:beef::1/64"
    DHCP6_START="fd00:dead:beef::10"
    DHCP6_END="fd00:dead:beef::99"

    DNSMASQ_PID="/tmp/''${NS}-dnsmasq.pid"
    DNSMASQ_LEASE="/tmp/''${NS}-dnsmasq.leases"

    # Error Handling & Cleanup Trap
    cleanup_on_fail() {
        echo "[enable-lab] ERROR: Script failed. Attempting cleanup..."
        ${pkgs.iproute2}/bin/ip netns delete "$NS" 2>/dev/null || true
        echo "[enable-lab] Cleanup complete. Exiting."
    }

    trap cleanup_on_fail ERR

    # Preflight
    if ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^''${NS}\b"; then
        echo "[enable-lab] ERROR: namespace ''${NS} already exists — tear it down first"
        trap - ERR
        exit 1
    fi

    command -v ${pkgs.dnsmasq}/bin/dnsmasq &>/dev/null || { echo "[enable-lab] ERROR: dnsmasq not found"; trap - ERR; exit 1; }

    [[ "$NUM_TAPS" =~ ^[1-9][0-9]*$ ]] || { echo "[enable-lab] ERROR: num_taps must be a positive integer"; trap - ERR; exit 1; }

    echo "[enable-lab] setting up isolated namespace=''${NS} taps=''${NUM_TAPS}"

    # Namespace Creation
    ${pkgs.iproute2}/bin/ip netns add "$NS"
    ${pkgs.iproute2}/bin/ip -n "$NS" link set lo up

    # Strict Routing Isolation
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.procps}/bin/sysctl -qw net.ipv4.ip_forward=0
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.procps}/bin/sysctl -qw net.ipv6.conf.all.forwarding=0

    # Bridge Setup
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link add br0 type bridge
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link set br0 up
    ${pkgs.iproute2}/bin/ip -n "$NS" addr add "$BR_CIDR4" dev br0
    ${pkgs.iproute2}/bin/ip -n "$NS" addr add "$BR_CIDR6" dev br0

    # Create TAP interfaces and attach to bridge
    for i in $(${pkgs.coreutils}/bin/seq 1 "$NUM_TAPS"); do
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip tuntap add dev "tap''${i}" mode tap
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link set "tap''${i}" master br0
        # NOTE: "isolated on" is REMOVED here so VMs can communicate with each other
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link set "tap''${i}" up
        echo "[enable-lab] created tap''${i} (connected to br0)"
    done

    # DHCP Services
    ${pkgs.iproute2}/bin/ip netns exec "$NS" \
        ${pkgs.dnsmasq}/bin/dnsmasq \
        --interface=br0 \
        --bind-interfaces \
        --port=0 \
        --dhcp-range="''${DHCP4_START},''${DHCP4_END},24h" \
        --dhcp-range="''${DHCP6_START},''${DHCP6_END},64,24h" \
        --enable-ra \
        --dhcp-option=option:router,"$BR_IP4" \
        --dhcp-option=option6:dns-server \
        --pid-file="$DNSMASQ_PID" \
        --dhcp-leasefile="$DNSMASQ_LEASE" \
        --log-facility=/dev/null

    echo "[enable-lab] dnsmasq running (PID=$(${pkgs.coreutils}/bin/cat "$DNSMASQ_PID")) in DHCP-only mode"

    # Done
    trap - ERR

    echo "[enable-lab] ready — ''${NUM_TAPS} tap(s) available in air-gapped namespace ''${NS}"
    echo "[enable-lab] launch VMs with:"
    for i in $(${pkgs.coreutils}/bin/seq 1 "$NUM_TAPS"); do
        echo "  sudo ip netns exec ''${NS} runuser -u \$USER -- qemu-system-x86_64 ... -netdev tap,id=net0,ifname=tap''${i},script=no,downscript=no ..."
    done
    echo "[enable-lab] tear down by deleting the namespace: sudo ip netns delete ''${NS}"
  '';
in
{
  home.packages = [ enable-lab ];
}
