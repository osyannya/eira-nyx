{ config, lib, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    settings = {
      main = {
        term = "foot";
        font = "JetBrainsMono Nerd Font:size=11";
        # dpi-aware = "yes";
      };

      colors = {
        background = "0f0f0f";
        foreground = "e5e5e5";

        regular0 = "1c1c1c"; # black
        regular1 = "d70000"; # red
        regular2 = "5faf00"; # green
        regular3 = "d7af00"; # yellow
        regular4 = "0087ff"; # blue
        regular5 = "af5fd7"; # magenta
        regular6 = "00afaf"; # cyan
        regular7 = "e4e4e4"; # white

        bright0 = "4e4e4e"; # bright black (gray)
        bright1 = "ff0000"; # bright red
        bright2 = "87ff00"; # bright green
        bright3 = "ffd700"; # bright yellow
        bright4 = "5fafff"; # bright blue
        bright5 = "d787ff"; # bright magenta
        bright6 = "00ffff"; # bright cyan
        bright7 = "ffffff"; # bright white
      };
    };
  };
}
