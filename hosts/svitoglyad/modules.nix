{ config, lib, pkgs, inputs, ... }:

let
  nixosBoot = "${inputs.self.outPath}/modules/nixos/boot";
  nixosCredentials = "${inputs.self.outPath}/modules/nixos/credentials";
  nixosFeatures = "${inputs.self.outPath}/modules/nixos/features";
  nixosPackages = "${inputs.self.outPath}/modules/nixos/packages";
  nixosPersistence = "${inputs.self.outPath}/modules/nixos/persistence";
  nixosPrograms = "${inputs.self.outPath}/modules/nixos/programs";
  nixosServices = "${inputs.self.outPath}/modules/nixos/services";
  nixosSystem = "${inputs.self.outPath}/modules/nixos/system";
in {
  imports = [
    "${nixosBoot}/early-systemd.nix"
    "${nixosBoot}/encryption.nix"
    "${nixosBoot}/initrd.nix"
    "${nixosBoot}/kernel.nix"
    "${nixosBoot}/loader.nix"

    "${nixosCredentials}/agenix.nix"

    "${nixosFeatures}/desktop/compositor/sway.nix"
    "${nixosFeatures}/desktop/file-manager/thunar.nix"
    "${nixosFeatures}/desktop/themes/adwaita-dark.nix"

    "${nixosFeatures}/fonts.nix"

    "${nixosFeatures}/networking/firewall/nftables.nix"
    "${nixosFeatures}/networking/interfaces.nix"
    "${nixosFeatures}/networking/wireless/wpa-supplicant.nix"

    "${nixosFeatures}/video/intel.nix"

    "${nixosFeatures}/virtualisation.nix"
    "${nixosFeatures}/zram.nix"

    "${nixosPackages}/core.nix"
    "${nixosPackages}/files.nix"
    "${nixosPackages}/hacking.nix"
    "${nixosPackages}/materials.nix" # try to move to home
    "${nixosPackages}/networking-tools.nix"
    "${nixosPackages}/security-tools.nix"

    "${nixosPersistence}/impermanence.nix"

    # "${nixosPrograms}/ghidra.nix"
    "${nixosPrograms}/git.nix"
    "${nixosPrograms}/mtr.nix"
    "${nixosPrograms}/nano.nix"
    "${nixosPrograms}/neovim.nix"
    "${nixosPrograms}/steam.nix"
    "${nixosPrograms}/tcpdump.nix"
    "${nixosPrograms}/tmux.nix"
    "${nixosPrograms}/vim.nix"
    "${nixosPrograms}/virt-manager.nix"
    "${nixosPrograms}/wireshark.nix"

    "${nixosServices}/audio.nix"
    "${nixosServices}/bluetooth.nix"
    "${nixosServices}/dbus.nix"
    "${nixosServices}/getty.nix"
    "${nixosServices}/logind.nix"
    "${nixosServices}/polkit.nix"
    "${nixosServices}/upower.nix"

    "${nixosSystem}/configuration.nix"
  ];
}
