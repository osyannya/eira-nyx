{ config, lib, pkgs, ... }:
let
  rootDevice = "/dev/mapper/crypted";
  maxSnapshots = 12;
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
    script = ''
      set -e
      VAULT_MOUNT="/run/btrfs-vault"
      cleanup() {
        if ${pkgs.util-linux}/bin/mountpoint -q "$VAULT_MOUNT"; then
          ${pkgs.util-linux}/bin/umount "$VAULT_MOUNT" || true
        fi
        ${pkgs.coreutils}/bin/rmdir "$VAULT_MOUNT" 2>/dev/null || true
      }
      trap cleanup EXIT
      ${pkgs.coreutils}/bin/mkdir -p "$VAULT_MOUNT"
      ${pkgs.util-linux}/bin/mount -t btrfs -o subvol=/ ${rootDevice} "$VAULT_MOUNT"
      SNAPSHOT_DIR="$VAULT_MOUNT/@persist_snapshots"
      ${pkgs.coreutils}/bin/mkdir -p "$SNAPSHOT_DIR"
      SNAPSHOTS=$(${pkgs.findutils}/bin/find "$SNAPSHOT_DIR" -maxdepth 1 -name 'boot-*' -type d | ${pkgs.coreutils}/bin/sort)
      CURRENT_COUNT=$(${pkgs.findutils}/bin/find "$SNAPSHOT_DIR" -maxdepth 1 -name 'boot-*' -type d | ${pkgs.coreutils}/bin/wc -l)
      if [ "$CURRENT_COUNT" -ge ${toString maxSnapshots} ]; then
        TO_DELETE=$((CURRENT_COUNT - ${toString maxSnapshots} + 1))
        echo "$SNAPSHOTS" | ${pkgs.coreutils}/bin/head -n "$TO_DELETE" | while read -r old_snap; do
          ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$old_snap"
        done
      fi
      TIMESTAMP=$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)
      NEW_SNAPSHOT="$SNAPSHOT_DIR/boot-$TIMESTAMP"
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r "$VAULT_MOUNT/@persist" "$NEW_SNAPSHOT"
      ${pkgs.coreutils}/bin/ln -sfn "boot-$TIMESTAMP" "$SNAPSHOT_DIR/latest.tmp"
      ${pkgs.coreutils}/bin/mv -T "$SNAPSHOT_DIR/latest.tmp" "$SNAPSHOT_DIR/latest"
    '';
  };
}
