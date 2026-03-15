{ config, lib, pkgs, ... }:

{
  # Start Sway after login
  home.file.".bash_profile".text = ''
  if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec sway --unsupported-gpu
  fi
  '';
}
