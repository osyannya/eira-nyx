# Disaster Recovery & Backup Runbook

> **⚠️ RECOVERY PHILOSOPHY**
> Eira-Nyx enforces a strict decoupling of the operating system state from persistent user data. Because the host configuration is fully declarative and reproducible via NixOS Flakes, there is zero requirement to back up the bootloader, the Nix store, or the root partition. The `@persist` subvolume contains the entirety of the system's irreplaceable state (cryptographic keys, database volumes, personal data) and is the exclusive target of this backup strategy.

## 1. State Replication Protocol

To achieve near-zero Recovery Point Objectives (RPO) without the overhead of file-level synchronization (e.g., `rsync`), this infrastructure utilizes native Btrfs block-level delta transfers. 

*Requirement: An external target drive formatted with a matching LUKS container and Btrfs filesystem.*

### 1.1 Baseline Initialization
Connect the external target, decrypt the LUKS volume, and mount it (e.g., to `/mnt/backup`). Push a read-only snapshot of the current persistent state to establish the baseline:

```bash
sudo btrfs subvolume snapshot -r /persist /persist_snapshots/backup-base
sudo btrfs send /persist_snapshots/backup-base | sudo btrfs receive /mnt/backup/
```

### 1.2 Routine Delta Replication
Subsequent replications transfer only modified blocks, executing in seconds regardless of total dataset size.

```bash
sudo btrfs subvolume snapshot -r /persist /persist_snapshots/backup-new
sudo btrfs send -p /persist_snapshots/backup-base /persist_snapshots/backup-new | sudo btrfs receive /mnt/backup/
```
*Maintenance Note: Post-transfer, rotate the baseline by pruning the old snapshot and designating `backup-new` as the future reference point.*

### 1.3 Out-of-Band Key Escrow
Digital backups are useless if the LUKS header is corrupted and the password fails. 
1. Replicate the generated `nvme-luks-header.img` to multiple, physically distinct offline locations. 
2. Print the 128-bit **Recovery Key** on physical media and secure it in a locked vault or safe.

---

## 2. Incident Response & Recovery Procedures

This section defines the precise operational procedures to restore system functionality and data integrity across three distinct failure tiers.

### Catastrophic Hardware Failure
**Condition:** The physical drive is dead. The ephemeral OS state is lost, but the declarative configuration (GitHub) and block-level data (USB Backup) survive.

1. Provision and install a replacement physical drive.
2. Boot from the NixOS live installation media.
3. Execute the declarative deployment sequence (`disko` partitioning and flake installation) as defined in `INSTALL.md`.
4. Mount the new drive's Btrfs top-level root (`subvolid=5`) to `/mnt`.
5. Connect and decrypt the external backup drive.
6. Inject the latest backup subvolume into the new host:
   ```bash
   sudo btrfs send /mnt/backup/backup-new | sudo btrfs receive /mnt/
   sudo mv /mnt/backup-new /mnt/@persist
   ```
7. **Reboot.** The system will evaluate the restored SSH keys, decrypt its secrets via `agenix`, and instantly resume its exact pre-failure state.

### EFI / Bootloader Corruption
**Condition:** An OS update, dual-boot fault, or firmware glitch corrupts `/boot` (the FAT32 EFI partition). The system fails to locate the bootloader. The encrypted payload remains mathematically intact.

1. Boot from the NixOS live installation media.
2. Escalate privileges and decrypt the primary LUKS partition:
   ```bash
   cryptsetup open /dev/nvme0n1p2 crypted
   ```
3. Mount the Btrfs root to `/mnt` and the corrupted `/boot` partition to `/mnt/boot`. *(If the FAT32 partition was destroyed, reformat it first).*
4. Chroot into the broken environment utilizing NixOS native tooling:
   ```bash
   nixos-enter --root /mnt
   ```
5. Force a native reinstallation of the bootloader:
   ```bash
   nixos-rebuild boot --install-bootloader
   ```
   > **⚠️ SECURE BOOT CRITICAL:** If Lanzaboote is enforcing Secure Boot, the newly generated Unified Kernel Image (UKI) must be signed. Execute `sbctl sign-all` while inside the `nixos-enter` chroot before exiting.

### Cryptographic Key Loss
**Condition:** Because `agenix` relies exclusively on the host/user SSH identities stored in `/persist/etc/ssh` and `/persist/home/mriya/.ssh`, the destruction of the `@persist` subvolume results in a total cryptographic lockout. 

1. Boot from the NixOS live installation media.
2. Decrypt the LUKS partition and mount the top-level Btrfs tree:
   ```bash
   cryptsetup open /dev/nvme0n1p2 crypted
   mount -o subvolid=5 /dev/mapper/crypted /mnt
   ```
3. **Attempt Local Snapshot Recovery:** If local automated snapshots survived the wipe, restore the subvolume directly:
   ```bash
   btrfs subvolume snapshot /mnt/@persist_snapshots/latest-good-snapshot /mnt/@persist
   ```
4. **Attempt External Target Recovery:** If local snapshots were destroyed, connect the external Btrfs backup target, decrypt it, and manually extract the identities:
   ```bash
   cp -a /mnt/backup/backup-new/etc/ssh/ssh_host_* /mnt/@persist/etc/ssh/
   cp -a /mnt/backup/backup-new/home/mriya/.ssh/* /mnt/@persist/home/mriya/.ssh/
   ```
5. Unmount and reboot. The `agenix` daemon will successfully parse the restored identities, decrypt the password hashes, and authorize user sessions.
