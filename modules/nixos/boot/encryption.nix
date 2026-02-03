{ config, lib, ... }:

{
  # Inspect hardware-configuration.nix
  boot.initrd.luks.devices = {
    luksroot = {
      device = lib.mkForce "/dev/disk/by-partlabel/cryptroot";
      allowDiscards = true;

      # TPM auto-unlock
      crypttabExtraOpts = [
        "tpm2-device=auto"
        "tpm2-pcrs=7"
      ];
    };

    luksswap = {
      device = lib.mkForce "/dev/disk/by-partlabel/cryptswap";
      allowDiscards = true;

      crypttabExtraOpts = [
        "tpm2-device=auto"
        "tpm2-pcrs=7"
      ];
    };
  };
}

# Changing luks passphrase
# cryptsetup luksChangeKey /dev/...
# cryptsetup luksAddKey /dev/...
# cryptsetup luksRemoveKey /dev/...

# Key file can be specified declaratively
# boot.initrd.luks.devices.<name>.keyFile
# boot.initrd.luks.devices.<name>.keyFileSize
# boot.initrd.luks.devices.<name>.keyFileOffset
# boot.initrd.secrets.<path>

# Enroll TPM & recovery keys (imperatively, from terminal once, can be removed)
# systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
# systemd-cryptenroll --recovery-key /dev/nvme0n1p2
# systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p3
# systemd-cryptenroll --recovery-key /dev/nvme0n1p3
