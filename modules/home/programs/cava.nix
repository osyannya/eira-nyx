{ config, lib, pkgs, ... }:

{
  programs.cava = {
    enable = true;
    package = pkgs.cava;
    settings = {
      general = {
        framerate = 60;
        bars = 0;
        bar_width = 2;
        bar_spacing = 1;
        autosens = 1;
      };

      color = {
        background = "'#000000'";
        foreground = "'#00afaf'";
        gradient = 1;
        gradient_color_1 = "'#00afaf'";
        gradient_color_2 = "'#0087ff'";
        gradient_color_3 = "'#af5fd7'";
      };

      output = {
        method = "ncurses";
      };

      input = {
        method = "pulse";
        source = "auto";
      };
    };
  };
}



