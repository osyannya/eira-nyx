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
        browsers.firefox.enable = true;
        communication.signal.enable = true;
        creativity.gimp.enable = true;
        media.enable = true;
        productivity = {
          libreoffice.enable = true;
          qalculate.enable = true;
          keepassxc.enable = true;
        };
      };
      security.impermanence.enable = true;
    };
  };
}
