{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.eira.home.programs.gaming;
  persistEnabled = config.eira.home.security.impermanence.enable or false;
  steamEnabled = osConfig.programs.steam.enable or false;
in {
  options.eira.home.programs.gaming = {
    lutris.enable = lib.mkEnableOption "Lutris game manager";
    prismlauncher.enable = lib.mkEnableOption "PrismLauncher for Minecraft";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.lutris.enable {
      programs.lutris = {
        enable = true;
        package = pkgs.lutris;
        extraPackages = with pkgs; [ mangohud winetricks gamescope gamemode umu-launcher ];
        protonPackages = with pkgs; [ proton-ge-bin ];
        winePackages = with pkgs; [ wineWow64Packages.full ];
      };
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".local/share/lutris" ];
      };
    })

    (lib.mkIf cfg.prismlauncher.enable {
      home.packages = [ pkgs.prismlauncher ];
      
      home.persistence."/persist" = lib.mkIf persistEnabled {
        directories = [ ".local/share/PrismLauncher" ];
      };
    })

    # System bridge for Steam persistence
    (lib.mkIf (steamEnabled && persistEnabled) {
      home.persistence."/persist".directories = [ ".local/share/Steam" ];
    })
  ];
}
