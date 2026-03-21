# ❄ Eira Nyx

## What is this?
This is a personal NixOS configuration which was built  on the principles of ephemerality, recoverability and simplicity. The repository is mostly used for syncing  changes between devices. The original idea was in creating a minimal config with multi host and multi user support. The modules are pretty minimal and composable hence can be reused by anyone.

## Why NixOS?
As it turned out NixOS was the first OS I had found that went along with my vision of a system that could not be broken, where everything is transparent, reproducible and behaves exactly as described.

## What is implemented?
1. Automatic partitioning
2. Encryption of a root partition
3. Declarative secrets management
4. Ephemeral root file system
5. Automatic snapshots of important data
6. Minimal working user environment
7. Ephemeral network settings for VMs

## Credentials
- personal.kdbx, keyfile.bin 
- host's and user's SSH key pairs 
- root's and user's passwords 

## How to deploy this flake?
> DO NOT ATTEMPT TO DEPLOY THIS FLAKE DIRECTLY
> This repository is a personal configuration tailored specifically to my machine's hardware and security model. If you attempt to install this flake on your system, it will fail.


## References
[Sway]: https://github.com/swaywm/sway
[foot]: https://codeberg.org/dnkl/foot
[Fcitx5]: https://github.com/fcitx/fcitx5
[Btop]: https://github.com/aristocratos/btop
[mpv]: https://github.com/mpv-player/mpv
[Neovim]: https://github.com/neovim/neovim
[imv]: https://sr.ht/~exec64/imv/
[OBS]: https://obsproject.com
[Nerd fonts]: https://github.com/ryanoasis/nerd-fonts
[wl-clipboard]: https://github.com/bugaevc/wl-clipboard
[thunar]: https://gitlab.xfce.org/xfce/thunar
[Btrfs]: https://btrfs.readthedocs.io
[LUKS]: https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system
[lanzaboote]: https://github.com/nix-community/lanzaboote
