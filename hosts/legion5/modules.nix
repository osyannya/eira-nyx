{ ... }:

let
  modulesNixOS = ../../modules/nixos;
in {
  imports = [
    # Boot
    (modulesNixOS + /boot/early-systemd.nix)
    # (modulesNixOS + /boot/initrd/ephemeral-root.nix)
    (modulesNixOS + /boot/kernel.nix)
    (modulesNixOS + /boot/lanzaboote.nix)
    (modulesNixOS + /boot/loader.nix)

    # Desktop
    (modulesNixOS + /desktop/compositor/sway.nix)
    (modulesNixOS + /desktop/file-manager/thunar.nix)
    (modulesNixOS + /desktop/fonts.nix)
    (modulesNixOS + /desktop/materials.nix)
    (modulesNixOS + /desktop/themes/adwaita-dark.nix)

    # Features
    # (modulesNixOS + /features/apparmor.nix)
    (modulesNixOS + /features/default.nix)
    (modulesNixOS + /features/zram.nix)

    # Network
    (modulesNixOS + /network/dns.nix)
    (modulesNixOS + /network/firewall/nftables.nix)
    (modulesNixOS + /network/interfaces.nix)
    (modulesNixOS + /network/tools.nix)
    (modulesNixOS + /network/wireless/wpa-supplicant.nix)

    # Packages
    (modulesNixOS + /packages/core.nix)
    (modulesNixOS + /packages/files.nix)
    (modulesNixOS + /packages/hacking.nix)
    (modulesNixOS + /packages/security.nix)

    # Programs
    (modulesNixOS + /programs/git.nix)
    (modulesNixOS + /programs/localsend.nix)
    (modulesNixOS + /programs/mtr.nix)
    (modulesNixOS + /programs/nano.nix)
    (modulesNixOS + /programs/neovim.nix)
    (modulesNixOS + /programs/steam.nix)
    (modulesNixOS + /programs/tcpdump.nix)
    (modulesNixOS + /programs/tmux.nix)
    (modulesNixOS + /programs/vim.nix)
    (modulesNixOS + /programs/wireshark.nix)

    # Services
    (modulesNixOS + /services/audio.nix)
    (modulesNixOS + /services/bluetooth.nix)
    (modulesNixOS + /services/dbus.nix)
    (modulesNixOS + /services/getty.nix)
    (modulesNixOS + /services/logind.nix)
    (modulesNixOS + /services/persist-snapshots.nix)
    (modulesNixOS + /services/polkit.nix)
    (modulesNixOS + /services/upower.nix)

    # Video
    # (modulesNixOS + /video/intel.nix)
    (modulesNixOS + /video/nvidia.nix)

    # Virtualisation
    # (modulesNixOS + /virtualisation/microvms/spotify-vm.nix)
  ];
}
