{ config, lib, pkgs, ... }:

{
  xdg = {
    autostart.enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";

        "audio/*" = ["mpv.desktop"];
        "video/*" = ["mpv.desktop"];
        "image/*" = ["imv.desktop"];

        "application/x-extension-htm" = "librewolf.desktop";
        "application/x-extension-html" = "librewolf.desktop";
        "application/x-extension-shtml" = "librewolf.desktop";
        "application/x-extension-xht" = "librewolf.desktop";
        "application/x-extension-xhtml" = "librewolf.desktop";
        "application/xhtml+xml" = "librewolf.desktop";
        "application/json" = "librewolf.desktop";
        "application/pdf" = ["librewolf.desktop"];
        "x-scheme-handler/spotify" = ["spotify.desktop"];
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
