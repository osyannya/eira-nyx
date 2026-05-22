{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.media;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;

  hasXdg = (config.options.xdg.mimeApps.enable or null) != null;
  xdgEnabled = hasXdg && config.xdg.mimeApps.enable;
in {
  options.eira.home.programs.media = {
    enable = lib.mkEnableOption "Pictures and videos";
  };

  config = lib.mkIf cfg.enable {
    programs.imv = {
      enable = true;
      package = pkgs.imv;
    };

    programs.mpv = {
      enable = true;
      package = pkgs.mpv;
    };

    xdg.mimeApps.defaultApplications = lib.mkIf xdgEnabled {
      "audio/*" = lib.mkDefault ["mpv.desktop"];
      "video/*" = lib.mkDefault ["mpv.desktop"];
      "image/*" = lib.mkDefault ["imv.desktop"];
    };

    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
    };

    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ ".config/obs-studio" ];
    };
  };
}
