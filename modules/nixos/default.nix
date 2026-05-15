{ ... }:

let
  sys = ./.;
in {
  imports = [
    # Boot
    (sys + /boot/default.nix)

    # Desktop
    (sys + /desktop/compositor/sway.nix)
    (sys + /desktop/displaymanager/greetd.nix)
    (sys + /desktop/fonts.nix)
    (sys + /desktop/materials.nix)
    (sys + /desktop/theme.nix)

    # Features
    (sys + /features/home-manager.nix)
    (sys + /features/overlays.nix)
    (sys + /features/stylix.nix)
    (sys + /features/zram.nix)

    # Network
    (sys + /network/default.nix)
    (sys + /network/dns.nix)
    (sys + /network/firewall.nix)
    (sys + /network/wireless.nix)

    # Programs
    (sys + /programs/localsend.nix)
    (sys + /programs/network-diagnostics.nix)
    (sys + /programs/pentesting.nix)
    (sys + /programs/steam.nix)
    (sys + /programs/thunar.nix)
    (sys + /programs/virt-manager.nix)

    # Security
    (sys + /security/apparmor.nix)
    (sys + /security/impermanence.nix)
    (sys + /security/sops.nix)

    # Services
    (sys + /services/audio.nix)
    (sys + /services/bluetooth.nix)
    (sys + /services/btrfs-lifecycle.nix)
    (sys + /services/openssh.nix)
    (sys + /services/power.nix)

    # Users
    (sys + /users/dynamic-users.nix)
    (sys + /users/mriya.nix)
    (sys + /users/root.nix)

    # Video
    (sys + /video/amd.nix)
    (sys + /video/intel.nix)
    (sys + /video/nvidia.nix)

    # Virtualisation
    (sys + /virtualisation/libvirtd.nix)
    (sys + /virtualisation/microvms/default.nix)
    (sys + /virtualisation/microvms/onion-vault.nix)
  ];
}
