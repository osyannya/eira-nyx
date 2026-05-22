{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.eira.system.features.stylix;
in {
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.eira.system.features.stylix = {
    enable = lib.mkEnableOption "Stylix module";

    defaultTheme = lib.mkOption {
      type = lib.types.str;
      default = "dracula";
      description = "Fallback base16 scheme";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      # Map the string to the massive base16-schemes package
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.defaultTheme}.yaml";

      # Stylix wallpaper 
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-dracula.png";
        sha256 = "1802p6q9id182p0x2zvh1qiv2q8js9231w9w6gxy2z1929mmj71g";
      };

      # Global cursor baseline
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      # Global typography baseline
      fonts = {
        monospace = {
          package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sizes = {
          terminal = 11;
          applications = 11;
        };
      };
    };
  };
}
