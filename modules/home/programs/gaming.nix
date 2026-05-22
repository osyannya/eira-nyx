{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.eira.home.programs.gaming;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
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
    })

    (lib.mkIf cfg.prismlauncher.enable {
      home.packages = [ pkgs.prismlauncher ];
    })

    # Persistent paths
    (lib.mkIf impermanenceEnabled {
      home.persistence."/persist" = {
        directories = 
          (lib.optionals cfg.lutris.enable [ ".local/share/lutris" ]) ++
          (lib.optionals cfg.prismlauncher.enable [ ".local/share/PrismLauncher" ]);
      };
    })
  ];
}
