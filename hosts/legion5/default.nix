# Default path: /etc/nixos/configuration.nix
# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, username, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan
      ./modules.nix
      # ./disko.nix
    ];

  # Hostname
  networking.hostName = "legion5";

  # Time zone
  time.timeZone = "Europe/Kyiv";

  # Locales
  i18n.defaultLocale = "en_US.UTF-8";

  # Terminal
  # console = {
    # enable = true;
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  # };

  # Default editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # programs.fuse.userAllowOther = true;

  users.mutableUsers = false;

  # Groups
  users.groups.network = {}; # used in networking

  # User account
  users.users.${username} = {
    isNormalUser = true;
    createHome = true;
    home = "/home/${username}";
    extraGroups = [
      "audio"
      "libvirtd"
      "network"
      # "networkmanager"
      # "vboxusers"
      "video" 
      # "vmware"
      "wheel" # allow sudo for user 
    ]; 
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
