{ config, lib, pkgs, ... }:

let 
  cfg = config.eira.home.desktop.bar.i3status-rust;
in {
  options.eira.home.desktop.bar.i3status-rust = {
    enable = lib.mkEnableOption "i3status-rust status bar";
  };

  config = lib.mkIf cfg.enable {
    programs.i3status-rust = {
      enable = true;

      bars.default = {
        icons = "awesome6";

        settings = {
          icons_format = "{icon}";
        };

        blocks = [
          {
            block = "net";
            format = " $icon ^icon_net_down $speed_down.eng(prefix:K) ^icon_net_up $speed_up.eng(prefix:K) ";
          }
          {
            block = "cpu";
            info_cpu = 20;
            warning_cpu = 50;
            critical_cpu = 90;
          }
          {
            block = "memory";
            format = " $icon $mem_total_used_percents.eng(w:2) ";
            format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
          }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            alert_unit = "GB";
            interval = 20;
            warning = 20.0;
            alert = 10.0;
            format = " $icon root: $available.eng(w:2) ";
          }
          {
            block = "sound";
            click = [
              {
                button = "left";
                cmd = "pavucontrol";
              }
            ];
          }
          {
            block = "backlight";
          }
          {
            block = "keyboard_layout";
            format = " $layout ";
            mappings = {
              "English (US)" = "US";
              "Ukrainian (N/A)" = "UA";
            };
          }
          {
            block = "time";
            interval = 10;
            format = " $icon $timestamp.datetime() ";
          }
          {
            block = "battery";
            format = " $icon $percentage ";
          }
        ];
      };
    };
  };
}
