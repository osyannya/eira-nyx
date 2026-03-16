{ config, lib, pkgs, ... }:

let
  rootDevice = "/dev/mapper/crypted";
  maxSnapshots = 8;
in {
  systemd.services.persist-snapshots = {
    description = "Capture pristine @persist state before user login";

    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    before = [ "systemd-user-sessions.service" ];

    serviceConfig = {
      Type = "oneshot";
      FailureAction = "none";
      RemainAfterExit = true;
    };
    path = [ pkgs.btrfs-progs pkgs.coreutils pkgs.findutils pkgs.util-linux ];

    script = ''
      set -e
      VAULT_MOUNT="/run/btrfs-vault"

      cleanup() {
        if mountpoint -q "$VAULT_MOUNT"; then
          umount "$VAULT_MOUNT" || true
        fi
        rmdir "$VAULT_MOUNT" 2>/dev/null || true
      }
      trap cleanup EXIT

      mkdir -p "$VAULT_MOUNT"
      mount -t btrfs -o subvol=/ ${rootDevice} "$VAULT_MOUNT"

      SNAPSHOT_DIR="$VAULT_MOUNT/@persist_snapshots"
      mkdir -p "$SNAPSHOT_DIR"

      SNAPSHOTS=$(find "$SNAPSHOT_DIR" -maxdepth 1 -name 'boot-*' -type d | sort)
      CURRENT_COUNT=$(find "$SNAPSHOT_DIR" -maxdepth 1 -name 'boot-*' -type d | wc -l)

      if [ "$CURRENT_COUNT" -ge ${toString maxSnapshots} ]; then
        TO_DELETE=$((CURRENT_COUNT - ${toString maxSnapshots} + 1))
        echo "$SNAPSHOTS" | head -n "$TO_DELETE" | while read -r old_snap; do
          btrfs subvolume delete "$old_snap"
        done
      fi

      # Atomic Capture
      TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
      NEW_SNAPSHOT="$SNAPSHOT_DIR/boot-$TIMESTAMP"
      btrfs subvolume snapshot -r "$VAULT_MOUNT/@persist" "$NEW_SNAPSHOT"

      ln -sfn "boot-$TIMESTAMP" "$SNAPSHOT_DIR/latest.tmp"
      mv -T "$SNAPSHOT_DIR/latest.tmp" "$SNAPSHOT_DIR/latest"
    '';
  };
}
