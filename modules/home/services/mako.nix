{ config, lib, pkgs, ... }:

{
  services.mako = {
    enable = true;
    package = pkgs.mako;
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      background-color = "#0f0f0fe6"; # ~90% opacity
      text-color = "#e5e5e5";
      border-color = "#af5fd7";
      border-size = 2;
      padding = "10";
      margin = "10";
      anchor = "top-right";
      default-timeout = 8000;
    };
  };
}
