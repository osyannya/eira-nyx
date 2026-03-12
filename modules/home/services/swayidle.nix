{ config, lib, pkgs, ... }:

let
  lockCommand = "${config.home.profileDirectory}/bin/swaylock-wrapper";
in
{
  services.swayidle = {
    enable = true;
    package = pkgs.swayidle;
    extraArgs = [ "-w" ];
    
    events = [
      {
        event = "before-sleep";
        command = lockCommand;
      }
      {
        event = "lock";
        command = lockCommand;
      }
    ];
    
    timeouts = [
      {
        timeout = 600;
        command = lockCommand;
      }
      {
        timeout = 900;
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 10%";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set 100%";
      }
      {
        timeout = 1200;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
      {
        timeout = 1800;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    
    systemdTarget = "sway-session.target";
  };
}
