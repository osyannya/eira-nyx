{ config, lib, ... }:
let
  rootDevice = "/dev/mapper/crypted";
in {
  # Ephemeral root script
  boot.initrd.systemd.services.ephemeral-root = {
    description = "Refresh btrfs root subvolume";
    wantedBy = ["initrd.target"];

    after = ["systemd-cryptsetup@crypted.service"];
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
