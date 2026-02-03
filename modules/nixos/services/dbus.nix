{ config, lib, pkgs, ... }:

{
  services.dbus = {
    enable = true;
    implementation = "broker"; # Default: dbus-daemon
  };
}
