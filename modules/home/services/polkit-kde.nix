{ config, lib, pkgs, ... }:

let
  agent = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
in {
  home.packages = with pkgs; [
    kdePackages.polkit-kde-agent-1
  ];

  systemd.user.services.kde-polkit-agent = {
    Unit = {
      Description = "KDE Polkit Authentication Agent";
      Documentation = [ "man:polkit(8)" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = agent;
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

