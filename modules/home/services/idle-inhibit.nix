{ config, lib, pkgs, ... }:

{
  # Idle-inhibitor
  home.packages = with pkgs; [
    wayland-pipewire-idle-inhibit
  ];

  systemd.user.services = {
    wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Wayland PipeWire idle inhibit";
        PartOf = [ "graphical-session.target" ]; # proper dependency
        After = [ "graphical-session.target" ]; # start only when session is ready
      };
      Service = {
        ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit --verbosity INFO";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ]; # auto-start with session
      };
    };
  };
}

