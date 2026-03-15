{ inputs, config, pkgs, ... }:

{
  imports = [
    ./modules.nix
  ];

  # Identity
  home = {
    username = "alva";
    homeDirectory = "/home/alva";
    stateVersion = "25.05";
  };
}
