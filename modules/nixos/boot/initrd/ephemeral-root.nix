{ config, lib, ... }:

let
  # The raw Btrfs device
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
    neededForBoot = true;
  };

  # Ephemeral root script
  boot.initrd.systemd.services.ephemeral-root = {
    description = "Rollback btrfs root subvolume";
    wantedBy = ["initrd.target"];

    after = ["systemd-cryptsetup@crypted.service"];
    before = ["sysroot.mount"];

    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    RemainAfterExit = true;

    script = ''
      cleanup() {
        if mountpoint -q /btrfs_tmp; then
          umount /btrfs_tmp || true
        fi
        rmdir /btrfs_tmp 2>/dev/null || true
      }
      trap cleanup EXIT

      mkdir -p /btrfs_tmp
      mount -o subvol=/ ${rootDevice} /btrfs_tmp

      if [[ -e /btrfs_tmp/@ ]]; then
        while IFS= read -r subvol; do
          btrfs subvolume delete "/btrfs_tmp/$subvol"
        done < <(btrfs subvolume list -o /btrfs_tmp/@ | awk '{sub(/.*path /,""); print}' | sort -r)

        btrfs subvolume delete /btrfs_tmp/@
      fi

      btrfs subvolume create /btrfs_tmp/@
      umount /btrfs_tmp
    '';
  };
}
