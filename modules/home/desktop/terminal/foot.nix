{ config, lib, pkgs, ... }:

let 
  cfg = config.eira.home.desktop.terminal.foot;
in {
  options.eira.home.desktop.terminal.foot = {
    enable = lib.mkEnableOption "Foot Wayland terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      package = pkgs.foot;
      settings = {
        main = {
          term = "foot";
        };
      };
    };
  };
}
