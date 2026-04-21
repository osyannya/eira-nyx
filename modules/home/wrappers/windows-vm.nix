{ config, lib, pkgs, ... }:

let
  windows-vm = pkgs.writeShellScriptBin "windows-vm" ''
    set -euo pipefail

    # Enforce root execution
    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: This script must be run as root."
        echo "Usage: sudo $0 -d <disk.qcow2> [options]"
        exit 1
    fi

    # Default parameters
    VM_ISO=""
    VM_VIRTIO_ISO=""
    VM_NS=""
    VM_TAP=""
    VM_RAM="8G"
    VM_CORES="2"
    VM_THREADS="1"

    # Dynamic Argument Parsing
    usage() {
        echo "Usage: sudo $0 -d <disk.qcow2> [-i boot.iso] [-v virtio.iso] [-n namespace] [-t tap] [-m ram] [-c cores] [-p threads]"
        echo "  -d  (REQUIRED) Path to the .qcow2 disk image"
        echo "  -i  (Optional) Path to Windows setup ISO"
        echo "  -v  (Optional) Path to VirtIO drivers ISO"
        echo "  -n  (Optional) Network namespace (default: empty)"
        echo "  -t  (Optional) TAP interface (default: empty)"
        echo "  -m  (Optional) Memory (default: 8G)"
        echo "  -c  (Optional) CPU Cores (default: 4)"
        echo "  -p  (Optional) CPU Threads per core (default: 1)"
        exit 1
    }

    while getopts "d:i:v:n:t:m:c:p:h" opt; do
        case $opt in
            d) VM_DISK=$(${pkgs.coreutils}/bin/realpath "$OPTARG") ;;
            i) VM_ISO=$(${pkgs.coreutils}/bin/realpath "$OPTARG") ;;
            v) VM_VIRTIO_ISO=$(${pkgs.coreutils}/bin/realpath "$OPTARG") ;;
            n) VM_NS="$OPTARG" ;;
            t) VM_TAP="$OPTARG" ;;
            m) VM_RAM="$OPTARG" ;;
            c) VM_CORES="$OPTARG" ;;
            p) VM_THREADS="$OPTARG" ;;
            h|\?) usage ;;
        esac
    done

    if [ -z "''${VM_DISK:-}" ]; then
        echo "ERROR: Disk image (-d) is required."
        usage
    fi

    # Dynamic context generation
    REAL_USER="''${SUDO_USER:-$USER}"
    USER_UID=$(${pkgs.coreutils}/bin/id -u "$REAL_USER")
    HOST_RUNTIME="/run/user/$USER_UID"
    HOST_AUDIO_IP="169.254.253.1"
    MACADDR=$(${pkgs.coreutils}/bin/printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    VM_NAME=$(${pkgs.coreutils}/bin/basename "$VM_DISK" .qcow2)

    TOTAL_THREADS=$((VM_CORES * VM_THREADS))
    CPU_QUOTA=$((TOTAL_THREADS * 100))

    # Auto-detect the host Wayland socket
    HOST_WAYLAND=$(${pkgs.coreutils}/bin/ls -1 "$HOST_RUNTIME"/wayland-* 2>/dev/null | ${pkgs.gnugrep}/bin/grep -v '\.lock' | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/basename || true)
    if [ -z "$HOST_WAYLAND" ]; then
        echo "ERROR: Could not detect a running Wayland compositor for $REAL_USER."
        exit 1
    fi

    # Handle optional Windows ISO mounting
    BIND_ISO=""
    QEMU_ISO=""
    if [ -n "$VM_ISO" ]; then
        BIND_ISO="--property=BindPaths=$VM_ISO:/tmp/boot.iso"
        QEMU_ISO="-drive file=/tmp/boot.iso,media=cdrom,readonly=on"
    fi

    # Handle optional VirtIO Drivers ISO mounting
    BIND_VIRTIO=""
    QEMU_VIRTIO=""
    if [ -n "$VM_VIRTIO_ISO" ]; then
        BIND_VIRTIO="--property=BindPaths=$VM_VIRTIO_ISO:/tmp/virtio-win.iso"
        QEMU_VIRTIO="-drive file=/tmp/virtio-win.iso,media=cdrom,readonly=on"
    fi

    # Handle optional networking
    BIND_NET=""
    QEMU_NET=""
    if [ -n "$VM_NS" ] && [ -n "$VM_TAP" ]; then
        BIND_NET="--property=NetworkNamespacePath=/run/netns/$VM_NS"
        QEMU_NET="-netdev tap,id=net0,ifname=$VM_TAP,script=no,downscript=no -device virtio-net-pci,netdev=net0,mac=$MACADDR,mq=on"
    fi

    # Audio Setup
    echo "Constructing TCP audio airlock for $VM_NAME..."
    ${pkgs.util-linux}/bin/runuser -u "$REAL_USER" -- ${pkgs.coreutils}/bin/env XDG_RUNTIME_DIR="$HOST_RUNTIME" \
        ${pkgs.pulseaudio}/bin/pactl load-module module-native-protocol-tcp listen="$HOST_AUDIO_IP" auth-anonymous=1 record=false >/dev/null 2>&1 || true

    # The execution wrapper
    echo "Launching Sandboxed Hypervisor Stack for Windows..."

    ${pkgs.systemd}/bin/systemd-run \
        --unit="qemu-''${VM_NAME}-''${RANDOM}" \
        $BIND_NET \
        --property=User="$REAL_USER" \
        --property=ProtectSystem=strict \
        --property=ProtectHome=tmpfs \
        --property=PrivateTmp=yes \
        --property=BindPaths="$VM_DISK:/tmp/vm.qcow2" \
        --property=BindPaths="${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd:/tmp/OVMF_CODE.fd" \
        $BIND_ISO \
        $BIND_VIRTIO \
        --property=BindPaths="$HOST_RUNTIME/$HOST_WAYLAND:/tmp/host-wayland" \
        --setenv=WAYLAND_DISPLAY="host-wayland" \
        --setenv=XDG_RUNTIME_DIR="/tmp" \
        --setenv=PATH="$PATH" \
        --setenv=SDL_VIDEODRIVER="wayland" \
        --setenv=MESA_SHADER_CACHE_DIR="/tmp" \
        --setenv=SDL_AUDIODRIVER="pulseaudio" \
        --setenv=PULSE_SERVER="tcp:$HOST_AUDIO_IP:4713" \
        --setenv=SDL_APP_NAME="$VM_NAME" \
        --property=CPUQuota="''${CPU_QUOTA}%" \
        --property=MemoryMax="$VM_RAM" \
        --wait --pty --collect \
        ${pkgs.cage}/bin/cage -- \
        ${pkgs.qemu}/bin/qemu-system-x86_64 \
        -name "$VM_NAME" \
        -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny \
        -enable-kvm \
        -machine q35,accel=kvm,usb=off,vmport=off,smm=on \
        -cpu host,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff,hv_time \
        -m "$VM_RAM" \
        -smp "$TOTAL_THREADS",sockets=1,cores="$VM_CORES",threads="$VM_THREADS" \
        -drive if=pflash,format=raw,readonly=on,file=/tmp/OVMF_CODE.fd \
        -drive file=/tmp/vm.qcow2,if=virtio,aio=native,cache=none,format=qcow2 \
        $QEMU_ISO \
        $QEMU_VIRTIO \
        $QEMU_NET \
        -device qemu-xhci \
        -device usb-tablet \
        -device virtio-vga,edid=on \
        -display sdl \
        -device virtio-sound-pci,audiodev=snd0 \
        -audiodev sdl,id=snd0 \
        -device virtio-rng-pci
  '';
in
{
  home.packages = [ windows-vm ];
}
