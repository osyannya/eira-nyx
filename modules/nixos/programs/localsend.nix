{ config, lib, pkgs, ... }:

{
  programs.localsend = {
    enable = true;
    package = pkgs.localsend;
  };
}
