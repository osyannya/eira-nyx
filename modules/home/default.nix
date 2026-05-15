{ ... }:

let
  home = ./.;
in {
  imports = [
    # Desktop
    (home + /desktop/bar/i3status-rust.nix)
    (home + /desktop/clipboard/cliphist.nix)
    (home + /desktop/compositor/sway.nix)
    (home + /desktop/idle/swayidle.nix)
    (home + /desktop/lockscreen/swaylock.nix)
    (home + /desktop/misc/fcitx5.nix)
    (home + /desktop/misc/idle-inhibit.nix)
    (home + /desktop/misc/wlsunset.nix)
    (home + /desktop/notifications/mako.nix)
    (home + /desktop/polkit/polkit-kde.nix)
    (home + /desktop/terminal/foot.nix)
    (home + /desktop/wrappers/my-clipboard.nix)
    (home + /desktop/wrappers/my-menu.nix)
    (home + /desktop/wrappers/screenshot-area.nix)
    (home + /desktop/wrappers/screenshot.nix)
    (home + /desktop/wrappers/swaylock-wrapper.nix)
    (home + /desktop/wrappers/wallpaper-switch.nix)
    (home + /desktop/xdg.nix)

    # Programs
    (home + /programs/browsers.nix)
    (home + /programs/communication.nix)
    (home + /programs/creativity.nix)
    (home + /programs/gaming.nix)
    (home + /programs/media.nix)
    (home + /programs/neovim.nix)
    (home + /programs/productivity.nix)
    (home + /programs/ssh.nix)
    (home + /programs/system-monitor.nix)
    (home + /programs/vscode.nix)

    # Security
    (home + /security/impermanence.nix)

    # Wrappers
    (home + /wrappers/connect-wifi.nix)
    (home + /wrappers/disable-wan.nix)
    (home + /wrappers/disconnect-wifi.nix)
    (home + /wrappers/enable-lab.nix)
    (home + /wrappers/enable-wan.nix)
    (home + /wrappers/firewall-switch.nix)
    (home + /wrappers/linux-vm.nix)
    (home + /wrappers/scan-wifi.nix)
    (home + /wrappers/stealth-vm.nix)
    (home + /wrappers/temporary-wifi.nix)
    (home + /wrappers/windows-vm.nix)
  ];
}
