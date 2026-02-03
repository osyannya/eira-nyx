{ config, lib, pkgs, ... }:

{
  # Polkit system service
  security.polkit.enable = true;
}
