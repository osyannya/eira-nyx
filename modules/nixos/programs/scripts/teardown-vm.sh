#!/usr/bin/env bash
# vm-net-down.sh <vm_index>
# Requires sudo. Safe to run after VM has exited, or to force-clean a crash.
set -euo pipefail

VM_INDEX="${1:?Usage: $0 <vm_index>}"
NS_VM="vmns-${VM_INDEX}"
NS_RTR="rtrns-${VM_INDEX}"
VETH_HOST="veth-host${VM_INDEX}"

echo "[net-down] tearing down VM_INDEX=${VM_INDEX}"

if ip link show "$VETH_HOST" &>/dev/null; then
  ip link del "$VETH_HOST"
  echo "[net-down] deleted veth pair ${VETH_HOST}"
fi

for NS in "$NS_VM" "$NS_RTR"; do
  if ip netns list | grep -q "^${NS}\b"; then
    ip netns del "$NS"
    echo "[net-down] deleted namespace ${NS}"
  fi
done

echo "[net-down] VM_INDEX=${VM_INDEX} fully torn down"
