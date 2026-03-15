{ ... }:

let
  modulesHome = ../../modules/home;
in {
  imports = [
    # Features
    (modulesHome + /features/desktop/compositor/sway.nix)
    (modulesHome + /features/desktop/cursors/bibata-modern.nix)
    (modulesHome + /features/desktop/themes/adwaita-dark.nix)
    (modulesHome + /features/desktop/variables.nix)
    (modulesHome + /features/desktop/xdg.nix)

    (modulesHome + /features/fcitx5.nix)

    (modulesHome + /features/home-files/bash-profile.nix)
    (modulesHome + /features/home-files/bashrc.nix)

    (modulesHome + /features/wrappers/my-clipboard.nix)
    (modulesHome + /features/wrappers/my-menu.nix)
    (modulesHome + /features/wrappers/screenshot-area.nix)
    (modulesHome + /features/wrappers/screenshot.nix)
    (modulesHome + /features/wrappers/swaylock-wrapper.nix)
    (modulesHome + /features/wrappers/translator.nix)

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
  ];
}
