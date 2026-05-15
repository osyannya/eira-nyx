{ lib, ... }:

{
  eira = {
    home = {
      desktop = {
        xdg.enable = true;
        compositor.sway = {
          keyboardLayout = "us";
        };
      };
      programs = {
        browsers = {
          firefox.enable = true;
          brave.enable = true;
        };
        communication.signal.enable = true;
        neovim.enable = true;
        vscode.enable = true;
        productivity = {
          joplin.enable = true;
          keepassxc.enable = true;
        };
        ssh.enable = true;
        systemMonitor.enable = true;
      };
      security.impermanence.enable = true;
    };
  };
}
