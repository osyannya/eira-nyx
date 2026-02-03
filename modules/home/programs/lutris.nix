{ config, lib, pkgs, ... }:

{
  programs.lutris = {
    enable = true;
    package = pkgs.lutris;
    extraPackages = with pkgs; [ mangohud winetricks gamescope gamemode umu-launcher ];
    # steamPackage = osConfig.programs.steam.package;
    protonPackages = with pkgs; [ proton-ge-bin ];
    winePackages = with pkgs; [ wineWow64Packages.full ];
  };
}
