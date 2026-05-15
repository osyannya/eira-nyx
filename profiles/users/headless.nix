{ lib, ... }:

{
  eira = {
    home = {
      desktop = {
        xdg.enable = true;
      };
      programs = {
        neovim.enable = true;
        ssh.enable = true;
        systemMonitor.enable = true;
      };
      security.impermanence.enable = true;
    };
  };
}
