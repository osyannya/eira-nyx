# What is this?
This is a personal NixOS configuration built  on the principles of ephemerality, recoverability and simplicity. The repo is mainly used for syncing  changes between devices. The original idea was creating a minimal config with multi host and multi user support. The modules are pretty minimal and universal and can be copied by anyone.

# What is implemented?
* Partitioning via disko with LUKS encryption
* Declarative secrets management using agenix
* Ephemeral file system thanks to btrfs subvolumes, init script for clearing root and impermanence module for persistent paths

# Credentials (what to protect)
1) personal.kdbx, keyfile.bin
2) Passwords.kdbx
3) Apps' passwords, tokens
4) ssh_host_ed25519_key, id_ed25519
5) root, user passwords
 
## Partitioning
Layout: GPT
 
***Partition 1***
Label: boot
Size: 512MiB 
Position: start of the disk

***Partition 2***
Label: cryptroot
File system: LUKS, btrfs (name - lukssroot)
Mount points: / (@) (label - nixos), /nix (@nix), /persist (@persist)
Size: depends on disk 
Position: right after boot partition.

***Partition 3***
Label: cryptswap
File system: LUKS, (name - luksswap), Linux swap (label - swap)
Size: 16GiB 
Position: right after root partition, end of the disk

Partitioning can be accomplished manually using parted, fdisk or declaratively using disko. Everything is stored in hardware-configuration.nix after installation.
 
OS: NixOS
Technologies: flakes, home-manager, agenix, impermanence
Microcode: Intel/AMD
Video: Intel, Nvidia (open), Radeon
 
## Boot
Kernel: Linux
Loader: systemd-boot
Init system: systemd
dbus implementation: broker
Login: getty
Shell: bash
Default editor: nvim
 
Virtualisation: QEMU/KVM, virt-manager
PAM: Linux-pam
Audio: pipewire
 
## Networking
Interface management: networkd
DNS: systemd-resolved
Wireless: wpa-supplicant (manual via script)
 
## Desktop
Compositor/WM: Sway
Display manager: none (autostart through .bash_profile)
Status bar: swaybar, i3status-rs
App launcher: wmenu
Wallpapers: swaybg (scripted)
File manager: Thunar (gvfs)
Terminal emulator: foot
Desktop portal: xdg-desktop-portal-wlr, xdg-desktop-portal-gtk
Notification daemon: mako
Clipboard: cliphist (wl-clipboard)
Authentication agent: polkit-kde-authentication-agent-1 (the most lightweight)
Secret service: Keepassxc
Login manager: Swaylock
Idle: Swayidle (wayland-idle-inhibit)
Theme: adwaita-dark
Cursor: bibata-modern
Icon theme: papirus
Images: imv
Video: mpv
Music daemon: mpd
Browsers: Brave, Firefox, Librewolf, Tor Browser

