{ config, lib, pkgs, ... }:

{
  programs.mtr = {
    enable = true;
    package = pkgs.mtr;
  };
}
