{ config, lib, pkgs, inputs, ... }:

let
  homeFeatures = "${inputs.self.outPath}/modules/home/features";
  homePackages = "${inputs.self.outPath}/modules/home/packages";
  homePrograms = "${inputs.self.outPath}/modules/home/programs";
  homeServices = "${inputs.self.outPath}/modules/home/services";
in {
  imports = [
    "${homeFeatures}/desktop/compositor/sway.nix"
    "${homeFeatures}/desktop/cursors/bibata-modern.nix"
    "${homeFeatures}/desktop/themes/adwaita-dark.nix"
    "${homeFeatures}/desktop/variables.nix"
    "${homeFeatures}/desktop/xdg.nix"

    "${homeFeatures}/fcitx5.nix"
    "${homeFeatures}/home-files/bash-profile.nix"
    "${homeFeatures}/home-files/bashrc.nix"
    "${homeFeatures}/wrappers/my-clipboard.nix"
    "${homeFeatures}/wrappers/my-menu.nix"
    "${homeFeatures}/wrappers/screenshot-area.nix"
    "${homeFeatures}/wrappers/screenshot.nix"
    "${homeFeatures}/wrappers/swaylock-wrapper.nix"
    "${homeFeatures}/wrappers/translator.nix"

    "${homePackages}/apps.nix"
    "${homePackages}/utils.nix"

    "${homePrograms}/btop.nix"
    "${homePrograms}/cava.nix"
    "${homePrograms}/fastfetch.nix"
    "${homePrograms}/firefox.nix"
    "${homePrograms}/foot.nix"
    "${homePrograms}/git.nix"
    "${homePrograms}/i3status-rust.nix"
    "${homePrograms}/imv.nix"
    "${homePrograms}/joplin-desktop.nix"
    "${homePrograms}/keepassxc.nix"
    "${homePrograms}/librewolf.nix"
    "${homePrograms}/lutris.nix"
    "${homePrograms}/mpv.nix"
    "${homePrograms}/ncmpcpp.nix"
    "${homePrograms}/obs-studio.nix"
    "${homePrograms}/swaylock.nix"
    "${homePrograms}/vscode.nix"

    "${homeServices}/cliphist.nix"
    "${homeServices}/idle-inhibit.nix"
    "${homeServices}/mako.nix"
    "${homeServices}/mpd.nix"
    "${homeServices}/polkit-kde.nix"
    "${homeServices}/swayidle.nix"
    "${homeServices}/wlsunset.nix"
  ];
}
