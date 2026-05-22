{ ... }:

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
          brave.enable = true;
          firefox.enable = true;
          librewolf.enable = true;
          tor.enable = true;
        };
        communication.signal.enable = true;
        creativity.gimp.enable = true;
        gaming = {
          lutris.enable = true;
          prismlauncher.enable = true;
        };
        media.enable = true;
        neovim.enable = true;
        productivity = {
          joplin.enable = true;
          keepassxc.enable = true;
          libreoffice.enable = true;
          qalculate.enable = true;
        };
        ssh.enable = true;
        swaylock.enable = true;
        systemMonitor.enable = true;
        vscode.enable = true;
      };
      security = {
        impermanence.enable = true;
      };
      wrappers = {
        connect-wifi.enable = true;
        disable-wan.enable = true;
        disconnect-wifi.enable = true;
        enable-lab.enable = true;
        enable-wan.enable = true;
        firewall-switch.enable = true;
        linux-vm.enable = true;
        scan-wifi.enable = true;
        stealth-vm.enable = true;
        temporary-wifi.enable = true;
        windows-vm.enable = true;
      };
    };
  };
}
