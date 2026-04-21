# Bare-Metal Provisioning Runbook

> **⚠️ ENVIRONMENT BOUNDARY WARNING** >  **Do not attempt to deploy this flake directly to foreign hardware.** Eira-Nyx is a strictly hardware-coupled, zero-trust infrastructure. Attempting to deploy this directly onto an unconfigured machine will result in boot failure due to mismatched hardware topologies and missing cryptographic keys. Use this runbook as an architectural reference for bootstrapping your own environments.

The following sequence outlines the fully declarative provisioning process from a live NixOS environment to a hardened state. The deployment relies on `disko` for block device orchestration and `agenix` for secure secret injection.

### Pre-Flight Environment

1. **Boot** the latest NixOS installation medium.
2. **Establish uplink** via Ethernet or Wi-Fi.
3. **Escalate to root**, as all subsequent provisioning commands require elevated privileges:
   ```bash
   sudo -i
   ```

### Declarative Block Device Provisioning

We utilize `disko` to automatically partition, format, and mount the storage arrays strictly according to the flake's definition. 

> **Warning:** Execution of this command is destructive and will irrevocably wipe the target drive(s).

```bash
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake github:osyannya/eira-nyx#svitoglyad
```

### Out-of-Band Secret Injection

Because Eira-Nyx enforces an ephemeral root (`tmpfs`), system and user secrets are decrypted via SSH identities stored securely in the `@persist` subvolume. The primary bootstrapping paradox is injecting these private keys securely *before* the first boot. Failure to correctly provision these keys will result in a total login lockout (mitigable only via rescue shell).

**1. Generate Ephemeral SSH Keypairs** Generate the keys without passphrases on a trusted machine:
```bash
# Host Identity
ssh-keygen -t ed25519 -f /tmp/svitoglyad-secrets/persist/etc/ssh/ssh_host_ed25519_key -C "root@svitoglyad" -N ""

# User Identity
ssh-keygen -t ed25519 -f /tmp/svitoglyad-secrets/home/mriya/.ssh/id_ed25519 -C "mriya@svitoglyad" -N ""
```

**2. Re-key the Secret Store** Add the newly generated public keys (`.pub`) to `secrets.nix` on the trusted machine, re-key the `.age` files, and push the changes to the repository. Transfer the private keys to the target machine via a secure channel.

**3. Construct the Persistent Hierarchy** Create the directories where the identities will survive reboots:
```bash
# Host
mkdir -p /persist/etc/ssh
# User
mkdir -p /persist/home/mriya/.ssh
```

**4. Restrict Permissions & Assign Ownership** Since the user `mriya` does not exist in the live environment, we map ownership to the default NixOS numeric IDs (UID 1000, GID 100) ensuring the keys are immediately usable by `agenix` on first boot.

```bash
# Secure the host key
chmod 600 /persist/etc/ssh/ssh_host_ed25519_key

# Secure the user key
chmod 700 /persist/home/mriya/.ssh
chmod 600 /persist/home/mriya/.ssh/id_ed25519
chmod 644 /persist/home/mriya/.ssh/id_ed25519.pub

# Assign ownership to the future user space
chown -R 1000:100 /persist/home/mriya/.ssh
```

### Hardware Topology Generation

Generate the specific hardware profile for the target machine and commit it to the repository so the flake can evaluate the correct kernel modules.

**1. Generate configuration** (bypassing filesystems, as `disko` manages block layers):
```bash
nixos-generate-config --no-filesystems --root /mnt --dir /tmp
```

**2. Clone and inject into the framework:**
```bash
git clone https://github.com/osyannya/eira-nyx.git /tmp/eira-nyx
cd /tmp/eira-nyx
cp /tmp/hardware-configuration.nix hosts/svitoglyad/
```

**3. Commit the new topology:**
*(Note: Committing from the live ISO requires git user configuration and authentication).*
```bash
git add hosts/svitoglyad/hardware-configuration.nix
git commit -m "refresh hardware topology for svitoglyad"
git push origin main
```

### Flake Deployment

With the block devices mounted, secrets injected, and hardware topology committed, execute the system installation.

**Deploy directly from the remote repository:**
```bash
nixos-install --flake github:osyannya/eira-nyx#svitoglyad --no-root-passwd
```

**Alternatively, deploy from the local clone:**
```bash
nixos-install --flake .#svitoglyad --no-root-passwd
```

Upon successful evaluation and installation, reboot into the newly provisioned architecture:
```bash
reboot
```

### Post-Deployment Cryptographic Binding

To finalize the zero-trust architecture, the environment must be bound to the hardware's cryptographic modules. This involves enrolling the storage volumes to the TPM2 module and provisioning custom Secure Boot keys via Lanzaboote.

> **⚠️ FIRMWARE REQUIREMENT** > Before executing the Secure Boot enrollment, you must reboot into your hardware's UEFI firmware interface and delete the factory PK (Platform Key). This places the motherboard into **Setup Mode**, allowing it to accept your custom-generated root of trust.

Execute the following sequences immediately upon your first successful login to the new system.

#### LUKS2 & TPM2 Binding
First, secure the block device recovery vectors and enable zero-interaction unlock tied to the firmware state (PCR 7).

```bash
# Export the LUKS Header for offline backup
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file /persist/nvme-luks-header.img

# Generate the physical Recovery Key
sudo systemd-cryptenroll --recovery-key /dev/nvme0n1p2

# Enroll the TPM2 module for zero-interaction unlock
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
```

#### Secure Boot Provisioning
Next, establish your custom Root of Trust. Because the root filesystem is ephemeral, the Secure Boot keys must be explicitly generated within the `@persist` subvolume to survive reboots.

```bash
# Generate the custom PK, KEK, and db keys
sudo sbctl create-keys --database-path /persist/var/lib/sbctl

# Enroll the custom keys into the UEFI firmware
# The '-m' flag includes Microsoft keys to ensure Option ROMs (like GPU drivers) still function
sudo sbctl enroll-keys --microsoft

# Verify the cryptographic chain of trust
sudo sbctl status
```

*Note: Once `sbctl status` confirms Setup Mode is disabled and Secure Boot is enabled, run `sudo nixos-rebuild boot` to ensure the UKI is signed with your newly generated keys for the next boot cycle.*
