{ config, lib, ... }:

let
  # The raw Btrfs device
  rootDevice = "/dev/disk/by-label/nixos";
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

  # Ephemeral root script
  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback btrfs root subvolume";
    wantedBy = ["initrd.target"];

    after = ["systemd-cryptsetup@luksroot.service"];
    before = ["sysroot.mount"];

    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";

    script = ''
      mkdir -p /btrfs_tmp
      mount -o subvol=/ ${rootDevice} /btrfs_tmp

      if [[ -e /btrfs_tmp/@ ]]; then
        for subvol in $(btrfs subvolume list -o /btrfs_tmp/@ | cut -f9- -d' ' | tac); do
          btrfs subvolume delete "/btrfs_tmp/$subvol"
        done

        btrfs subvolume delete /btrfs_tmp/@
      fi

      btrfs subvolume create /btrfs_tmp/@
      umount /btrfs_tmp
    '';
  };
}
