{ config, lib, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    package = pkgs.librewolf;
  };
}
