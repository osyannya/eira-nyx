{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./modules.nix
  ];

  # programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };
}
