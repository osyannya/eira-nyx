{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.media;
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

    xdg.mimeApps.defaultApplications = lib.mkIf (config.xdg.mimeApps.enable or false) {
      "audio/*" = lib.mkDefault ["mpv.desktop"];
      "video/*" = lib.mkDefault ["mpv.desktop"];
      "image/*" = lib.mkDefault ["imv.desktop"];
    };

    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
    };

    home.persistence."/persist" = lib.mkIf (config.eira.home.security.impermanence.enable or false) {
      directories = [ ".config/obs-studio" ];
    };
  };
}
