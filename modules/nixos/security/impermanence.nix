{ inputs, config, lib, ... }:

let
  cfg = config.eira.system.security.impermanence;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.eira.system.security.impermanence = {
    enable = lib.mkEnableOption "Impermanence";

    extraDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Host-specific directories to persist.";
    };

    extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "Host-specific files to persist.";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/log"
      ] ++ cfg.extraDirectories;

      files = [
        { file = "/etc/machine-id"; parentDirectory = { mode = "0644"; }; }
      ] ++ cfg.extraFiles;
    };
  };
}
