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
    path = [ pkgs.btrfs-progs pkgs.coreutils pkgs.openssh pkgs.file pkgs.util-linux ];

    script = ''
      set -e

      MNTPOINT="/btrfs_tmp"
      ROOT_DEVICE="/dev/mapper/crypted"
      PERSIST_SUBVOL="$MNTPOINT/@persist"
      SNAPSHOT_LINK="$MNTPOINT/@persist_snapshots/latest"
      SNAPSHOT_BASE="$MNTPOINT/@persist_snapshots"

      # Critical files
      CRITICAL_FILES=(
        "/persist/etc/ssh/ssh_host_ed25519_key"
        # "/persist/etc/machine-id"
      )

      cleanup() {
        if mountpoint -q "$MNTPOINT"; then
          umount "$MNTPOINT" || true
        fi
        rmdir "$MNTPOINT" 2>/dev/null || true
      }
      trap cleanup EXIT

      mkdir -p "$MNTPOINT"
      mount -t btrfs -o subvol=/ "$ROOT_DEVICE" "$MNTPOINT"

      # Resolve snapshot
      if [ -d "$SNAPSHOT_LINK" ]; then
        SNAPSHOT="$SNAPSHOT_LINK"
      else
        echo "WARNING: latest symlink missing or broken, scanning for newest snapshot..."
        SNAPSHOT=$(find "$SNAPSHOT_BASE" -maxdepth 1 -name 'boot-*' -type d | sort | tail -n 1)
      fi

      # Verify @persist exists and is a real btrfs subvolume
      VERIFICATION_FAILED=0

      if [ ! -d "$PERSIST_SUBVOL" ]; then
        echo "CRITICAL: @persist subvolume is missing!"
        VERIFICATION_FAILED=1
      elif ! btrfs subvolume show "$PERSIST_SUBVOL" > /dev/null 2>&1; then
        echo "CRITICAL: @persist exists but is not a valid btrfs subvolume!"
        VERIFICATION_FAILED=1
      fi

      # Verify critical files
      if [ $VERIFICATION_FAILED -eq 0 ]; then
        for BOOTED_PATH in "''${CRITICAL_FILES[@]}"; do

          # Strip /persist prefix to get path relative to @persist
          REL_PATH="''${BOOTED_PATH#/persist}"
          FILE="$PERSIST_SUBVOL$REL_PATH"

          # Existence + non-empty
          if [ ! -s "$FILE" ]; then
            echo "CRITICAL: $BOOTED_PATH is missing or empty!"
            VERIFICATION_FAILED=1
            continue
          fi

          # Format detection via `file` magic bytes
          FILE_TYPE=$(file -b "$FILE")

          case "$FILE_TYPE" in

            # Host SSH private key or user SSH private key
            *"OpenSSH private key"*)
              if ! ssh-keygen -y -f "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid OpenSSH private key!"
                VERIFICATION_FAILED=1
              fi
            ;;

            # machine-id: 32 lowercase hex chars, single line
            *"ASCII text"*)
              if echo "$FILE" | grep -q "machine-id"; then
                if ! grep -qE '^[0-9a-f]{32}$' "$FILE"; then
                  echo "CRITICAL: $BOOTED_PATH is not a valid machine-id!"
                  VERIFICATION_FAILED=1
                fi
              fi
            ;;

            # KDBX database
            *"Keepass"*|*"keepass"*)
              MAGIC=$(head -c 4 "$FILE" | xxd -p)
              if [ "$MAGIC" != "03d9a29a" ]; then
                echo "CRITICAL: $BOOTED_PATH is not a valid KDBX file!"
                VERIFICATION_FAILED=1
              fi
            ;;

            # ELF binary
            *"ELF"*)
              if ! echo "$FILE_TYPE" | grep -q "ELF"; then
                echo "CRITICAL: $BOOTED_PATH is not a valid ELF binary!"
                VERIFICATION_FAILED=1
              fi
            ;;

            # tar.gz / tgz and other compressed archives
            *"gzip compressed"*)
              if ! gzip -t "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid gzip archive!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *"Zip archive"*|*"zip"*)
              if ! unzip -t "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid zip archive!"
                VERIFICATION_FAILED=1
              fi
            ;;

            # jex — Joplin export, which is a tar archive
            *"POSIX tar"*|*"tar archive"*)
              if ! tar -tf "$FILE" > /dev/null 2>&1; then
                echo "CRITICAL: $BOOTED_PATH is not a valid tar archive!"
                VERIFICATION_FAILED=1
              fi
            ;;

            *)
              # Unknown format existence
              echo "WARNING: $BOOTED_PATH has unrecognized format: $FILE_TYPE"
              echo "WARNING: Only existence was verified for $BOOTED_PATH"
            ;;

          esac
        done
      fi

      # Restore or continue
      if [ $VERIFICATION_FAILED -eq 1 ]; then
        echo "Verification failed. Initiating restore from snapshot..."

        if [ -z "$SNAPSHOT" ] || [ ! -d "$SNAPSHOT" ]; then
          echo "FATAL: No valid snapshot found. Cannot recover."
          exit 1
        fi

        if [ -d "$PERSIST_SUBVOL" ]; then
          echo "Deleting corrupted @persist..."
          while IFS= read -r subvol; do
            btrfs subvolume delete "$MNTPOINT/$subvol"
          done < <(btrfs subvolume list -o "$PERSIST_SUBVOL" | awk '{print $NF}' | sort -r)
          btrfs subvolume delete "$PERSIST_SUBVOL"
        fi

        echo "Restoring @persist from: $SNAPSHOT"
        btrfs subvolume snapshot "$SNAPSHOT" "$PERSIST_SUBVOL"
        echo "Restore complete. Proceeding with boot."
      else
        echo "@persist verified. No anomalies detected."
      fi
    '';
  };
}
