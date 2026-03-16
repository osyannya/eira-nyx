{ config, lib, pkgs, ... }:

let
  rootDevice = "/dev/mapper/crypted";
in {
  boot.initrd.systemd.enable = true;

    # Override the auto-generated mounts with label-based ones
  fileSystems."/" = lib.mkForce {
    device = rootDevice;
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/nix" = lib.mkForce {
    device = rootDevice;
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  fileSystems."/persist" = lib.mkForce {
    device = rootDevice;
    fsType = "btrfs";
    options = [ "subvol=@persist" ];
    neededForBoot = true;
  };

  fileSystems."/.swap" = lib.mkForce {
    device = rootDevice;
    fsType = "btrfs";
    options = [ "subvol=@swap" ];
  };

  # Ephemeral root script
  boot.initrd.systemd.services.ephemeral-root = {
    description = "Rollback btrfs root subvolume";
    wantedBy = ["initrd.target"];

    after = ["systemd-cryptsetup@crypted.service"];
    before = ["sysroot.mount"];

    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      cleanup() {
        if ${pkgs.util-linux}/bin/mountpoint -q /btrfs_tmp; then
          ${pkgs.util-linux}/bin/umount /btrfs_tmp || true
        fi
       ${pkgs.coreutils}/bin/rmdir /btrfs_tmp 2>/dev/null || true
      }
      trap cleanup EXIT
      ${pkgs.coreutils}/bin/mkdir -p /btrfs_tmp
      ${pkgs.util-linux}/bin/mount -o subvol=/ ${rootDevice} /btrfs_tmp
      if [[ -e /btrfs_tmp/@ ]]; then
        while IFS= read -r subvol; do
          ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "/btrfs_tmp/$subvol"
        done < <(${pkgs.btrfs-progs}/bin/btrfs subvolume list -o /btrfs_tmp/@ | ${pkgs.gawk}/bin/awk '{sub(/.*path /,""); print}' | ${pkgs.coreutils}/bin/sort -r)
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /btrfs_tmp/@
      fi
      ${pkgs.btrfs-progs}/bin/btrfs subvolume create /btrfs_tmp/@
      ${pkgs.util-linux}/bin/umount /btrfs_tmp
    '';
  };
}
