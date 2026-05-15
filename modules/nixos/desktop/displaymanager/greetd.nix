{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.desktop.displaymanager.greetd;
in {
  options.eira.system.desktop.displaymanager.greetd = {
    enable = lib.mkEnableOption "Greetd display manager with Tuigreet";

    defaultSession = lib.mkOption {
      type = lib.types.str;
      default = "sway";
      description = "The default session command to launch";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${cfg.defaultSession}";
          user = "greeter";
        };
      };
    };

    # Prevent kernel boot messages
    boot.kernelParams = [ "console=tty2" ];
  };
}
