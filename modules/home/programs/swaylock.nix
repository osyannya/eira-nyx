{ config, lib, pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      color = "ffffff";
      show-failed-attempts = true;
    };
  };
}
