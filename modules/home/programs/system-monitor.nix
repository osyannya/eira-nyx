{ config, lib, pkgs, osConfig, ... }:

let 
  cfg = config.eira.home.programs.systemMonitor;

  hasWireplumber = (osConfig.options.services.pipewire.wireplumber.enable or null) != null;
  wireplumberEnabled = hasWireplumber && osConfig.services.pipewire.wireplumber.enable;
in {
  options.eira.home.programs.systemMonitor = {
    enable = lib.mkEnableOption "System monitoring tools";
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      package = pkgs.btop;
    };

    programs.cava = {
      enable = lib.attrByPath [ "eira" "system" "services" "audio" "enable" ] false osConfig;
      package = pkgs.cava;
      settings = {
        general = {
          framerate = 60;
          bars = 0;
          bar_width = 2;
          bar_spacing = 1;
          autosens = 1;
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

    programs.fastfetch = {
      enable = true;
      package = pkgs.fastfetch;
    };

    home.packages = [ pkgs.inxi ];
  };
}
