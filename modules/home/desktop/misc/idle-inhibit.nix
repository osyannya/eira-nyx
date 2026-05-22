{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.desktop.misc.idle-inhibit;
in {
  options.eira.home.desktop.misc.idle-inhibit = {
    enable = lib.mkEnableOption "Wayland PipeWire idle inhibitor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wayland-pipewire-idle-inhibit
    ];

    systemd.user.services.wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Wayland PipeWire idle inhibit";
        PartOf = [ "graphical-session.target" ]; 
        After = [ "graphical-session.target" ]; 
      };
      Service = {
        ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit --verbosity INFO";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
