{ config, lib, pkgs, ... }:

{
  boot.initrd.systemd.services.persist-verification = {
    description = "Verify and auto-restore BTRFS @persist subvolume";
    wantedBy = [ "initrd.target" ];
    after = [ "systemd-cryptsetup@crypted.service" "ephemeral-root.service" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -e

      MNTPOINT="/btrfs_tmp"
      ROOT_DEVICE="/dev/mapper/crypted"
      PERSIST_SUBVOL="$MNTPOINT/@persist"
      SNAPSHOT_LINK="$MNTPOINT/@persist_snapshots/latest"
      SNAPSHOT_BASE="$MNTPOINT/@persist_snapshots"

      CRITICAL_FILES=(
        "/persist/etc/ssh/ssh_host_ed25519_key"
        # "/persist/etc/machine-id"
      )

      cleanup() {
        if ${pkgs.util-linux}/bin/mountpoint -q "$MNTPOINT"; then
          ${pkgs.util-linux}/bin/umount "$MNTPOINT" || true
        fi
        ${pkgs.coreutils}/bin/rmdir "$MNTPOINT" 2>/dev/null || true
      }
      trap cleanup EXIT

      ${pkgs.coreutils}/bin/mkdir -p "$MNTPOINT"
      ${pkgs.util-linux}/bin/mount -t btrfs -o subvol=/ "$ROOT_DEVICE" "$MNTPOINT"

      # Resolve snapshot
      if [ -d "$SNAPSHOT_LINK" ]; then
        SNAPSHOT="$SNAPSHOT_LINK"
      else
        echo "WARNING: latest symlink missing or broken, scanning for newest snapshot..."
        SNAPSHOT=$(${pkgs.findutils}/bin/find "$SNAPSHOT_BASE" -maxdepth 1 -name 'boot-*' -type d | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/tail -n 1)
      fi

      VERIFICATION_FAILED=0

      if [ ! -d "$PERSIST_SUBVOL" ]; then
        echo "CRITICAL: @persist subvolume is missing!"
        VERIFICATION_FAILED=1
      elif ! ${pkgs.btrfs-progs}/bin/btrfs subvolume show "$PERSIST_SUBVOL" > /dev/null 2>&1; then
        echo "CRITICAL: @persist exists but is not a valid btrfs subvolume!"
        VERIFICATION_FAILED=1
      fi

      if [ $VERIFICATION_FAILED -eq 0 ]; then
        for BOOTED_PATH in "''${CRITICAL_FILES[@]}"; do

          REL_PATH="''${BOOTED_PATH#/persist}"
          FILE="$PERSIST_SUBVOL$REL_PATH"

          if [ ! -s "$FILE" ]; then
            echo "CRITICAL: $BOOTED_PATH is missing or empty!"
            VERIFICATION_FAILED=1
            continue
          fi

          FILE_TYPE=$(${pkgs.file}/bin/file -b "$FILE")

          case "$FILE_TYPE" in

            *"OpenSSH private key"*)
              if ! ${pkgs.openssh}/bin/ssh-keygen -y -f "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid OpenSSH private key!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *"ASCII text"*)
              if echo "$FILE" | ${pkgs.gnugrep}/bin/grep -q "machine-id"; then
                if ! ${pkgs.gnugrep}/bin/grep -qE '^[0-9a-f]{32}$' "$FILE"; then
                  echo "CRITICAL: $BOOTED_PATH is not a valid machine-id!"
                  VERIFICATION_FAILED=1
                fi
              fi
            ;;

            *"Keepass"*|*"keepass"*)
              MAGIC=$(${pkgs.coreutils}/bin/head -c 4 "$FILE" | ${pkgs.xxd}/bin/xxd -p)
              if [ "$MAGIC" != "03d9a29a" ]; then
                echo "CRITICAL: $BOOTED_PATH is not a valid KDBX file!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *"ELF"*)
              if ! echo "$FILE_TYPE" | ${pkgs.gnugrep}/bin/grep -q "ELF"; then
                echo "CRITICAL: $BOOTED_PATH is not a valid ELF binary!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *"gzip compressed"*)
              if ! ${pkgs.gzip}/bin/gzip -t "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid gzip archive!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *"Zip archive"*|*"zip"*)
              if ! ${pkgs.unzip}/bin/unzip -t "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid zip archive!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *"POSIX tar"*|*"tar archive"*)
              if ! ${pkgs.gnutar}/bin/tar -tf "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid tar archive!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *)
              echo "WARNING: $BOOTED_PATH has unrecognized format: $FILE_TYPE"
              echo "WARNING: Only existence was verified for $BOOTED_PATH"
            ;;

          esac
        done
      fi

      if [ $VERIFICATION_FAILED -eq 1 ]; then
        echo "Verification failed. Initiating restore from snapshot..."

        if [ -z "$SNAPSHOT" ] || [ ! -d "$SNAPSHOT" ]; then
          echo "FATAL: No valid snapshot found. Cannot recover."
          exit 1
        fi

        if [ -d "$PERSIST_SUBVOL" ]; then
          echo "Deleting corrupted @persist..."
          while IFS= read -r subvol; do
            ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$MNTPOINT/$subvol"
          done < <(${pkgs.btrfs-progs}/bin/btrfs subvolume list -o "$PERSIST_SUBVOL" | ${pkgs.gawk}/bin/awk '{sub(/.*path /,""); print}' | ${pkgs.coreutils}/bin/sort -r)
          ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$PERSIST_SUBVOL"
        fi

        echo "Restoring @persist from: $SNAPSHOT"
        ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot "$SNAPSHOT" "$PERSIST_SUBVOL"
        echo "Restore complete. Proceeding with boot."
      else
        echo "@persist verified. No anomalies detected."
      fi
    '';
  };
}
