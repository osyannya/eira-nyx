{ ... }:

let
  modulesHome = ../../modules/home;
in {
  imports = [
    # Desktop
    (modulesHome + /desktop/compositor/sway.nix)
    (modulesHome + /desktop/cursors/bibata-modern.nix)
    (modulesHome + /desktop/themes/adwaita-dark.nix)
    (modulesHome + /desktop/variables.nix)
    (modulesHome + /desktop/xdg.nix)

    # Features
    (modulesHome + /features/fcitx5.nix)

    # Files
    (modulesHome + /files/bash-profile.nix)
    (modulesHome + /files/bashrc.nix)

    # Packages
    (modulesHome + /packages/apps.nix)
    (modulesHome + /packages/utils.nix)

    # Programs
    (modulesHome + /programs/btop.nix)
    (modulesHome + /programs/cava.nix)
    (modulesHome + /programs/fastfetch.nix)
    (modulesHome + /programs/firefox.nix)
    (modulesHome + /programs/foot.nix)
    (modulesHome + /programs/git.nix)
    (modulesHome + /programs/i3status-rust.nix)
    (modulesHome + /programs/imv.nix)
    (modulesHome + /programs/joplin-desktop.nix)
    (modulesHome + /programs/keepassxc.nix)
    (modulesHome + /programs/librewolf.nix)
    (modulesHome + /programs/lutris.nix)
    (modulesHome + /programs/mpv.nix)
    (modulesHome + /programs/ncmpcpp.nix)
    (modulesHome + /programs/obs-studio.nix)
    (modulesHome + /programs/swaylock.nix)
    (modulesHome + /programs/vscode.nix)

    # Services
    (modulesHome + /services/cliphist.nix)
    (modulesHome + /services/idle-inhibit.nix)
    (modulesHome + /services/mako.nix)
    (modulesHome + /services/mpd.nix)
    (modulesHome + /services/polkit-kde.nix)
    (modulesHome + /services/swayidle.nix)
    (modulesHome + /services/wlsunset.nix)

    # Wrappers
    (modulesHome + /wrappers/my-clipboard.nix)
    (modulesHome + /wrappers/my-menu.nix)
    (modulesHome + /wrappers/screenshot-area.nix)
    (modulesHome + /wrappers/screenshot.nix)
    (modulesHome + /wrappers/script-wrapper.nix)
    (modulesHome + /wrappers/swaylock-wrapper.nix)
  ];
}
