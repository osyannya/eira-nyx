#!/usr/bin/env bash
# vm-start.sh <vm_index> <iso_path>
# Requires sudo.
set -euo pipefail

VM_INDEX="${1:?Usage: $0 <vm_index> <iso_path>}"
ISO="$(realpath "${2:?Usage: $0 <vm_index> <iso_path>}")"
NS_VM="vmns-${VM_INDEX}"
CGROUP_PATH="/sys/fs/cgroup/qemu-vm${VM_INDEX}"
QEMU_ROOT="/tmp/qemu-root-${VM_INDEX}"

INVOKING_UID="${SUDO_UID:?must be run via sudo, not as root directly}"
INVOKING_GID="${SUDO_GID:?must be run via sudo, not as root directly}"
INVOKING_USER="$(getent passwd "$INVOKING_UID" | cut -d: -f1)"

MAC=$(printf '02:00:%02x:%02x:%02x:%02x\n' \
  $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

# ── Preflight ────────────────────────────────────────────────────
if ! ip netns list | grep -q "^${NS_VM}\b"; then
  echo "[vm-start] ERROR: ${NS_VM} not found — run vm-net-up.sh first"
  exit 1
fi

[[ -f "$ISO" ]] || { echo "[vm-start] ERROR: ISO not found: ${ISO}"; exit 1; }

for cmd in qemu-system-x86_64 qemu-img; do
  command -v "$cmd" &>/dev/null || { echo "[vm-start] ERROR: missing ${cmd}"; exit 1; }
done

[[ -r /dev/kvm && -w /dev/kvm ]] || { echo "[vm-start] ERROR: cannot access /dev/kvm"; exit 1; }

# ── Seccomp ──────────────────────────────────────────────────────
if qemu-system-x86_64 -sandbox on,obsolete=deny -version &>/dev/null 2>&1; then
  SECCOMP_FLAGS="-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny"
else
  echo "[vm-start] WARNING: QEMU sandbox not available"
  SECCOMP_FLAGS=""
fi

# ── Disk image ───────────────────────────────────────────────────
IMG="$(mktemp /tmp/vm-disk-${VM_INDEX}-XXXXXX.qcow2)"
qemu-img create -f qcow2 "$IMG" 16G

# ── cgroup v2 ────────────────────────────────────────────────────
mkdir -p "$CGROUP_PATH"
# 2 CPUs: 200000us quota per 100000us period
echo "200000 100000"                   > "${CGROUP_PATH}/cpu.max"
echo "$(( 4 * 1024 * 1024 * 1024 ))" > "${CGROUP_PATH}/memory.max"
echo "$(( 4 * 1024 * 1024 * 1024 ))" > "${CGROUP_PATH}/memory.swap.max"

# ── Mount namespace root ─────────────────────────────────────────
# Bind-mount only ISO and disk into a private tmpfs so QEMU cannot
# access the rest of the host filesystem.
mkdir -p "$QEMU_ROOT"
mount -t tmpfs tmpfs "$QEMU_ROOT"
mkdir -p "${QEMU_ROOT}/dev" "${QEMU_ROOT}/iso" "${QEMU_ROOT}/disk"
mount -t devtmpfs devtmpfs "${QEMU_ROOT}/dev"
touch "${QEMU_ROOT}/iso/boot.iso"
touch "${QEMU_ROOT}/disk/vm.qcow2"
mount --bind "$ISO" "${QEMU_ROOT}/iso/boot.iso"
mount --bind "$IMG" "${QEMU_ROOT}/disk/vm.qcow2"

chown -R "$INVOKING_USER" "$QEMU_ROOT/iso"
chown -R "$INVOKING_USER" "$QEMU_ROOT/disk"

# ── Cleanup ──────────────────────────────────────────────────────
cleanup() {
  umount -lf "${QEMU_ROOT}/iso/boot.iso"  2>/dev/null || true
  umount -lf "${QEMU_ROOT}/disk/vm.qcow2" 2>/dev/null || true
  umount -lf "${QEMU_ROOT}/dev"           2>/dev/null || true
  umount -lf "$QEMU_ROOT"                 2>/dev/null || true
  rm -rf "$QEMU_ROOT"
  rmdir  "$CGROUP_PATH" 2>/dev/null || true
  rm -f  "$IMG"
  rm -f  "/tmp/qemu-monitor-${VM_INDEX}.sock"
  "$(dirname "$0")/vm-net-down.sh" "$VM_INDEX"
}
trap cleanup EXIT

echo "[vm-start] VM_INDEX=${VM_INDEX} IMG=${IMG} MAC=${MAC}"

# ── Launch QEMU ──────────────────────────────────────────────────
# Enter network namespace as root, then drop to invoking user for QEMU.
# runuser executes QEMU as the real user — a VM escape lands as them,
# not root. The mount namespace (unshare --mount) is entered first so
# QEMU sees only QEMU_ROOT, not the host filesystem.
ip netns exec "$NS_VM" \
  unshare --mount --propagation slave \
    runuser -u "$INVOKING_USER" -- \
      qemu-system-x86_64 \
        -enable-kvm \
        -cpu host \
        -smp 2 \
        -m 4G \
        -drive file="${QEMU_ROOT}/disk/vm.qcow2",format=qcow2,if=virtio,discard=unmap \
        -cdrom "${QEMU_ROOT}/iso/boot.iso" \
        -boot order=d,menu=on \
        -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
        -device virtio-net-pci,netdev=net0,mac="$MAC" \
        -device virtio-rng-pci \
        -vga virtio \
        -display sdl,gl=on \
        -monitor unix:/tmp/qemu-monitor-${VM_INDEX}.sock,server,nowait \
        ${SECCOMP_FLAGS} &

QEMU_PID=$!
echo "$QEMU_PID" > "${CGROUP_PATH}/cgroup.procs"
echo "[vm-start] QEMU PID=${QEMU_PID} cgroup=qemu-vm${VM_INDEX}"

wait "$QEMU_PID"
