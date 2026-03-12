#!/usr/bin/env bash
# vm-net-up.sh <vm_index> <uplink>
set -euo pipefail

VM_INDEX="${1:?Usage: $0 <vm_index> <uplink>}"
UPLINK="${2:?Usage: $0 <vm_index> <uplink>}"

NS_VM="vmns-${VM_INDEX}"
NS_RTR="rtrns-${VM_INDEX}"

IDX2=$(( VM_INDEX * 2 ))
IDX1=$(( IDX2 - 1 ))

VM_IP="10.200.${IDX1}.2/30"
RTR_VM_IP="10.200.${IDX1}.1/30"
RTR_VM_GW="10.200.${IDX1}.1"
RTR_HOST_IP="10.200.${IDX2}.2/30"
HOST_IP="10.200.${IDX2}.1/30"
HOST_GW="10.200.${IDX2}.1"

VETH_VM="veth-vm${VM_INDEX}"
VETH_RTR="veth-rtr${VM_INDEX}"
VETH_HOST="veth-host${VM_INDEX}"
VETH_UP="veth-up${VM_INDEX}"

echo "[net-up] VM_INDEX=${VM_INDEX} NS_VM=${NS_VM} NS_RTR=${NS_RTR}"

# Namespaces
ip netns add "$NS_VM"
ip netns add "$NS_RTR"

# Veth: VM namespace - Router namespace
ip link add "$VETH_VM"  type veth peer name "$VETH_RTR"
ip link set "$VETH_VM"  netns "$NS_VM"
ip link set "$VETH_RTR" netns "$NS_RTR"

# Veth: Router namespace ↔ Host namespace
ip link add "$VETH_HOST" type veth peer name "$VETH_UP"
ip link set "$VETH_UP"   netns "$NS_RTR"

# VM namespace
ip -n "$NS_VM" link set lo up
ip -n "$NS_VM" link set "$VETH_VM" up

# Bridge ties veth-vmN and tap0 together at L2
ip netns exec "$NS_VM" ip link add br0 type bridge
ip netns exec "$NS_VM" ip link set "$VETH_VM" master br0
ip netns exec "$NS_VM" ip tuntap add dev tap0 mode tap
ip netns exec "$NS_VM" ip link set tap0 master br0
ip netns exec "$NS_VM" ip link set tap0 up
ip netns exec "$NS_VM" ip link set br0 up

ip -n "$NS_VM" addr add "$VM_IP" dev br0
ip -n "$NS_VM" route add default via "$RTR_VM_GW"
ip netns exec "$NS_VM" sysctl -qw net.ipv6.conf.all.disable_ipv6=1

# Router namespace
ip -n "$NS_RTR" link set lo up
ip -n "$NS_RTR" link set "$VETH_RTR" up
ip -n "$NS_RTR" link set "$VETH_UP"  up
ip -n "$NS_RTR" addr add "$RTR_VM_IP"   dev "$VETH_RTR"
ip -n "$NS_RTR" addr add "$RTR_HOST_IP" dev "$VETH_UP"
ip netns exec "$NS_RTR" sysctl -qw net.ipv4.ip_forward=1
ip netns exec "$NS_RTR" sysctl -qw net.ipv6.conf.all.disable_ipv6=1
ip netns exec "$NS_RTR" ip route add default via "$HOST_GW"

# Host side
ip link set "$VETH_HOST" up
ip addr add "$HOST_IP"   dev "$VETH_HOST"
# No route to VM subnet — host cannot initiate connections to VMs

# NAT + firewall in router namespace
ip netns exec "$NS_RTR" nft -f - <<EOF
table inet filter {
  chain forward {
    type filter hook forward priority 0;
    policy drop;
    iif "${VETH_RTR}" oif "${VETH_UP}" accept
    iif "${VETH_UP}"  oif "${VETH_RTR}" ct state established,related accept
  }
}
table ip nat {
  chain postrouting {
    type nat hook postrouting priority 100;
    oif "${VETH_UP}" masquerade
  }
}
EOF

echo "[net-up] done — NS_VM=${NS_VM} ready, tap0 available for QEMU"
