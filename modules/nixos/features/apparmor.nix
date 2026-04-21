{ config, lib, pkgs, ... }:

{
  security.apparmor = {
    enable = true;
    # packages = pkgs.apparmor-profiles;
  };
}
