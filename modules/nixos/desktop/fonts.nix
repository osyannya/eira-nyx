{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.desktop.fonts;
in {
  options.eira.system.desktop.fonts = {
    enable = lib.mkEnableOption "System-wide typography";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        fira-code
        font-awesome
        inter
        ipaexfont
        jetbrains-mono
        hack-font
        montserrat
        merriweather
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];
    };
  };
}
