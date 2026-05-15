{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.eira.home.desktop.compositor.sway;
in {
  options.eira.home.desktop.compositor.sway = {
    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Keyboard layout strings injected dynamically by users.json";
    };

    extraOutputs = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Raw Sway output directives injected by the NixOS host file";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Automatically start Sway from TTY1 if no other graphical session is running";
    };
  };

  # Only evaluate this if Sway is active on the NixOS system level
  config = lib.mkIf (osConfig.eira.system.desktop.compositor.sway.enable or false) {

    # Start Sway after login in tty
    programs.bash.profileExtra = lib.mkIf (cfg.autoStart && (config.programs.bash.enable or false)) ''
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec systemd-cat -t sway sway --unsupported-gpu
      fi
    '';

    programs.zsh.loginExtra = lib.mkIf (cfg.autoStart && (config.programs.zsh.enable or false)) ''
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec systemd-cat -t sway sway --unsupported-gpu
      fi
    '';

    programs.fish.loginShellInit = lib.mkIf (cfg.autoStart && (config.programs.fish.enable or false)) ''
      if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a "$(tty)" = "/dev/tty1"
        exec systemd-cat -t sway sway --unsupported-gpu
      end
    '';

    # Minimal Sway environment 
    eira.home.desktop = {
      bar.i3status-rust.enable = true;
      clipboard.cliphist.enable = true;
      idle.swayidle.enable = true;
      lockscreen.swaylock.enable = true;
      misc = {
        fcitx5.enable = true;
        idle-inhibit.enable = true;
        wlsunset.enable = true;
      };
      notifications.mako.enable = true;
      polkit.polkit-kde.enable = true;
      terminal.foot.enable = true;
      wrappers = {
        my-clipboard.enable = true;
        my-menu.enable = true;
        screenshot-area.enable = true;
        screenshot.enable = true;
        swaylock-wrapper.enable = true;
        wallpaper-switch.enable = true;
      };
    };

    # Required system packages
    home.packages = with pkgs; [
      brightnessctl
      grim
      slurp
      libnotify
      pavucontrol
      wmenu
      swaybg
    ];

    wayland.windowManager.sway = {
      enable = true;

      wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps

      extraSessionCommands = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';

      config = {
        modifier = "Mod4";
        terminal = "foot";
        menu = "my-menu";

        defaultWorkspace = "workspace number 1";

        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;
          term = config.wayland.windowManager.sway.config.terminal;
          menu = config.wayland.windowManager.sway.config.menu;
        in {
          # Basics
          "${mod}+Return" = "exec ${term}";
          "${mod}+d" = "exec ${menu}";
          "${mod}+Shift+q" = "kill";
          "${mod}+Print" = "exec screenshot";
          "${mod}+Shift+Print" = "exec screenshot-area";
          "${mod}+Shift+v" = "exec my-clipboard";
          "${mod}+Escape" = "exec swaylock-wrapper";

          # Focus movement with Vim keys
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # Focus movement with arrows
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          # Move windows with Vim keys + Shift
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # Move windows with arrows + Shift
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # Resize mode
          "${mod}+r" = "mode resize";

          # Layout stuff
          "${mod}+b" = "splith";
          "${mod}+v" = "splitv";

          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";

          "${mod}+f" = "fullscreen";
          "${mod}+Shift+space" = "floating toggle";

          # Scratchpad
          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+minus" = "scratchpad show";

          # Switch to workspace
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          # Move focused container to workspace
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";
        };

        modes = {
          resize = {
            h = "resize shrink width 10px";
            j = "resize grow height 10px";
            k = "resize shrink height 10px";
            l = "resize grow width 10px";

            Left = "resize shrink width 10px";
            Down = "resize grow height 10px";
            Up = "resize shrink height 10px";
            Right = "resize grow width 10px";

            Return = "mode default";
            Escape = "mode default";
          };
        };

        startup = [
          { command = "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME"; }
          { command = "wallpaper-switch random"; }
        ];

        gaps.inner = 10;
        focus.followMouse = true;

        input = {
          "*" = {
            xkb_layout = cfg.keyboardLayout; # API INJECTED
            xkb_options = "grp:alt_shift_toggle";
          };

          "type:touchpad" = {
            tap = "enabled"; # Enable tap-to-click
            tap_button_map = "lrm"; # 1-finger: left, 2-finger: right, 3-finger: middle
            dwt = "enabled"; # Disable while typing  
            dwtp = "enabled"; # Disable while using trackpoint
          };
        };
      };

      # Extra raw Sway directives
      extraConfig = ''
        force_display_urgency_hint 500
        titlebar_border_thickness 1
        titlebar_padding 5 1

        default_border normal
        default_floating_border normal

        for_window [app_id="imv"] floating enable
        for_window [app_id="mpv"] floating enable
        for_window [app_id="pavucontrol"] floating enable
        for_window [app_id="qalculate-gtk"] floating enable
        for_window [app_id="xdg-desktop-portal-gtk"] floating enable
        for_window [app_id="xdg-desktop-portal-wlr"] floating enable

        for_window [instance="update_installer"] floating enable

        for_window [title="File Operation Progress"] floating enable
        for_window [title="List"] floating enable
        for_window [title="Open"] floating enable
        for_window [title="Picture-in-Picture"] floating enable
        for_window [title="Rename"] floating enable
        for_window [title="Steam Settings"] floating enable

        for_window [window_role="bubble"] floating enable
        for_window [window_role="pop-up"] floating enable
        for_window [window_role="Preferences"] floating enable
        for_window [window_role="task_dialog"] floating enable

        for_window [window_type="dialog"] floating enable
        for_window [window_type="menu"] floating enable

        # Host specific monitor
        ${cfg.extraOutputs}
      '';
    };
  };
}
