{ config, lib, pkgs, ... }:

let
  enable-wan = pkgs.writeShellScriptBin "enable-wan" ''
    set -euo pipefail

    NUM_TAPS="''${1:?Usage: $0 <num_taps> <uplink>}"
    UPLINK="''${2:?Usage: $0 <num_taps> <uplink>}"
    NS="wanns"

    # Atypical subnet: 172.31.253.0/24
    BR_IP="172.31.253.1"
    BR_CIDR="172.31.253.1/24"
    DHCP_START="172.31.253.10"
    DHCP_END="172.31.253.254"

    # Point-to-point link between wanns and host: 169.254.253.0/30
    VETH_WAN_IP="169.254.253.2/30"
    VETH_HOST_IP="169.254.253.1/30"
    HOST_GW="169.254.253.1"
    VETH_WAN="veth-wan"
    VETH_HOST="veth-host-wan"

    DNSMASQ_PID="/tmp/wanns-dnsmasq.pid"
    DNSMASQ_LEASE="/tmp/wanns-dnsmasq.leases"

    # nft table names
    NFT_TABLE_NAT="inet wan-vm-nat"
    NFT_TABLE_FILTER="inet wan-vm-filter"
    NFT_TABLE_HOST="inet wan-vm-host-isolation"

    # Error Handling & Cleanup Trap
    cleanup_on_fail() {
        echo "[enable-wan] ERROR: Script failed. Attempting partial cleanup..."
        ${pkgs.iproute2}/bin/ip netns delete "$NS" 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip link delete "$VETH_HOST" 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete table inet wan-vm-nat 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete table inet wan-vm-filter 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete table inet wan-vm-host-isolation 2>/dev/null || true

        ${pkgs.nftables}/bin/nft delete rule inet filter input iifname "$VETH_HOST" accept 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete rule inet filter output oifname "$VETH_HOST" accept 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete rule inet filter forward iifname "$VETH_HOST" oifname "$UPLINK" accept 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete rule inet filter forward iifname "$UPLINK" oifname "$VETH_HOST" ct state established,related accept 2>/dev/null || true

        echo "[enable-wan] Cleanup complete. Exiting."
    }

    trap cleanup_on_fail ERR

    # Preflight
    if ${pkgs.iproute2}/bin/ip netns list | ${pkgs.gnugrep}/bin/grep -q "^''${NS}\b"; then
        echo "[enable-wan] ERROR: namespace ''${NS} already exists — run disable-wan.sh first"
        trap - ERR
        exit 1
    fi

    command -v ${pkgs.dnsmasq}/bin/dnsmasq &>/dev/null || { echo "[enable-wan] ERROR: dnsmasq not found"; trap - ERR; exit 1; }
    command -v ${pkgs.nftables}/bin/nft &>/dev/null || { echo "[enable-wan] ERROR: nft not found"; trap - ERR; exit 1; }

    if ! ${pkgs.iproute2}/bin/ip link show "$UPLINK" &>/dev/null; then
        echo "[enable-wan] ERROR: uplink ''${UPLINK} not found"
        trap - ERR
        exit 1
    fi

    [[ "$NUM_TAPS" =~ ^[1-9][0-9]*$ ]] || { echo "[enable-wan] ERROR: num_taps must be a positive integer"; trap - ERR; exit 1; }

    echo "[enable-wan] setting up namespace=''${NS} taps=''${NUM_TAPS} uplink=''${UPLINK}"

    # Namespace & Veth Wiring
    ${pkgs.iproute2}/bin/ip netns add "$NS"
    ${pkgs.iproute2}/bin/ip link add "$VETH_HOST" type veth peer name "$VETH_WAN"
    ${pkgs.iproute2}/bin/ip link set "$VETH_WAN" netns "$NS"
    ${pkgs.iproute2}/bin/ip link set "$VETH_HOST" up
    ${pkgs.iproute2}/bin/ip addr add "$VETH_HOST_IP" dev "$VETH_HOST"

    ${pkgs.iproute2}/bin/ip -n "$NS" link set lo up
    ${pkgs.iproute2}/bin/ip -n "$NS" link set "$VETH_WAN" up
    ${pkgs.iproute2}/bin/ip -n "$NS" addr add "$VETH_WAN_IP" dev "$VETH_WAN"

    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip route add default via "$HOST_GW"
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.procps}/bin/sysctl -qw net.ipv4.ip_forward=1
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.procps}/bin/sysctl -qw net.ipv6.conf.all.disable_ipv6=1

    # Bridge & TAP Interfaces (Layer 2 Isolation)
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link add br0 type bridge
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link set br0 up
    ${pkgs.iproute2}/bin/ip -n "$NS" addr add "$BR_CIDR" dev br0

    for i in $(${pkgs.coreutils}/bin/seq 1 "$NUM_TAPS"); do
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip tuntap add dev "tap''${i}" mode tap
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link set "tap''${i}" master br0
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/bridge link set dev "tap''${i}" isolated on
        ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.iproute2}/bin/ip link set "tap''${i}" up
        echo "[enable-wan] created tap''${i} (isolated)"
    done

    # Host Firewall (NAT, Filtering, Host Isolation)
    ${pkgs.procps}/bin/sysctl -qw net.ipv4.ip_forward=1

    ${pkgs.nftables}/bin/nft insert rule inet filter input iifname "$VETH_HOST" accept
    ${pkgs.nftables}/bin/nft insert rule inet filter output oifname "$VETH_HOST" accept
    ${pkgs.nftables}/bin/nft insert rule inet filter forward iifname "$VETH_HOST" oifname "$UPLINK" accept
    ${pkgs.nftables}/bin/nft insert rule inet filter forward iifname "$UPLINK" oifname "$VETH_HOST" ct state established,related accept

    ${pkgs.nftables}/bin/nft -f - <<EOF
    table ''${NFT_TABLE_NAT} {
        chain postrouting {
            type nat hook postrouting priority srcnat;
            # Consolidated Masquerade
            ip saddr { 172.31.253.0/24, 169.254.253.0/30 } oif "''${UPLINK}" masquerade
        }
    }

    table ''${NFT_TABLE_FILTER} {
        chain forward {
            type filter hook forward priority filter;
            # VM -> internet
            iif "''${VETH_HOST}" oif "''${UPLINK}" \
            ip daddr != { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, \
            169.254.0.0/16, 127.0.0.0/8 } \
            accept

            # Internet -> VM: return traffic only
            iif "''${UPLINK}" oif "''${VETH_HOST}" \
            ct state established,related accept

            # Drop anything else transiting veth-host-wan
            iif "''${VETH_HOST}" drop
            oif "''${VETH_HOST}" drop
        }
    }

    table ''${NFT_TABLE_HOST} {
        chain output {
            type filter hook output priority filter;
            # Host must never initiate connections into the VM subnet
            oif "''${VETH_HOST}" ip daddr 172.31.253.0/24 drop
        }
        chain input {
            type filter hook input priority filter;
            # Drop new unsolicited packets from VM subnet arriving at the host
            iif "''${VETH_HOST}" ip saddr 172.31.253.0/24 ct state new drop
        }
    }
    EOF

    echo "[enable-wan] host nftables rules loaded"

    # Namespace Internal Firewall
    ${pkgs.iproute2}/bin/ip netns exec "$NS" ${pkgs.nftables}/bin/nft -f - <<EOF
    table inet filter {
        chain input {
            type filter hook input priority 0;
            policy drop;
            # Core operations
            iif "lo" accept
            ct state established,related accept
            # Allow VMs to reach dnsmasq
            iif "br0" tcp dport 53 accept
            iif "br0" udp dport 53 accept
            iif "br0" udp dport 67 accept
        }
        chain forward {
            type filter hook forward priority 0;
            policy drop;
            # VM -> internet
            iif "br0" oif "''${VETH_WAN}" accept
            # Return traffic
            iif "''${VETH_WAN}" oif "br0" ct state established,related accept
        }
        chain output {
            type filter hook output priority 0;
            policy accept;
        }
    }
    EOF

    # DHCP & DNS Services
    ${pkgs.iproute2}/bin/ip netns exec "$NS" \
        ${pkgs.dnsmasq}/bin/dnsmasq \
        --interface=br0 \
        --bind-interfaces \
        --dhcp-range="''${DHCP_START},''${DHCP_END},24h" \
        --dhcp-option=option:router,"$BR_IP" \
        --dhcp-option=option:dns-server,"$BR_IP" \
        --no-resolv \
        --server=1.1.1.1 \
        --server=9.9.9.9 \
        --pid-file="$DNSMASQ_PID" \
        --dhcp-leasefile="$DNSMASQ_LEASE" \
        --log-facility=/dev/null

    echo "[enable-wan] dnsmasq running (PID=$(${pkgs.coreutils}/bin/cat "$DNSMASQ_PID"))"

    ${pkgs.iproute2}/bin/ip route add 172.31.253.0/24 via 169.254.253.2 dev "$VETH_HOST"
    echo "[enable-wan] host routing updated for 172.31.253.0/24"

    # Done
    # Remove the trap upon successful completion
    trap - ERR

    echo "[enable-wan] ready — ''${NUM_TAPS} tap(s) available in namespace ''${NS}"
    echo "[enable-wan] launch VMs with:"
    for i in $(${pkgs.coreutils}/bin/seq 1 "$NUM_TAPS"); do
        echo "  sudo ip netns exec ''${NS} runuser -u \$USER -- qemu-system-x86_64 ... -netdev tap,id=net0,ifname=tap''${i},script=no,downscript=no ..."
    done
    echo "[enable-wan] tear down with: sudo disable-wan.sh"
  '';
in
{
  home.packages = [ enable-wan ];
}
