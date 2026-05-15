{ lib, ... }:

{
  eira = {
    home = {
      desktop = {
        xdg.enable = true;
        compositor.sway = {
          keyboardLayout = "us"; # Can be overridden by the dynamic-users JSON
        };
      };
      programs = {
        browsers = {
          librewolf.enable = true;
          tor.enable = true;
        };
        communication.signal.enable = true;
        neovim.enable = true;
        productivity.keepassxc.enable = true;
        ssh.enable = true;
        systemMonitor.enable = true;
      };
      security.impermanence.enable = true;
    };
  };
}
