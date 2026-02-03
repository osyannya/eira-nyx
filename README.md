# What is this?
This is a personal NixOS configuration built  with the principles of ephemerality, recoverability and simplicity. The repo is mainly used for syncing  changes between devices. The original idea was creating a minimal config with multi host and multi user support.

# What is implemented
GPT
## Partition 1
Label: boot
Destiny: boot
File system: fat32
Mount point: /boot 
Size: 512MiB, start of the disk

## Partition 2
Label: cryptroot
Destiny: root
File system: LUKS container, btrfs (lukssroot)
Mount points: / (@) (nixos), /nix (@nix), /persist (@persist)
Size: depends on disk, right after boot partition.

## Partition 3
Label: cryptswap
Destiny: swap
File system: LUKS container (luksswap), Linux swap (swap)
Size: last 16GiB on the disk
