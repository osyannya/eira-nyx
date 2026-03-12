{ config, lib, pkgs, ... }:

{
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
}
