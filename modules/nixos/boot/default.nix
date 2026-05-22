{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.boot;

  hasImpermanence = (config.options.eira.system.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.system.security.impermanence.enable;
in {
  options.eira.system.boot = {
    loader = {
      systemdBoot.enable = lib.mkEnableOption "Standard systemd-boot EFI bootloader";
      secureBoot.enable = lib.mkEnableOption "Lanzaboote secure boot";
    };
    earlySystemd.enable = lib.mkEnableOption "Systemd in initrd";
  };

  config = lib.mkMerge [
    # Explicit Guardrail: Assert that both bootloaders cannot be active simultaneously
    {
      assertions = [
        {
          assertion = !(cfg.loader.systemdBoot.enable && cfg.loader.secureBoot.enable);
          message = "eira.system.boot.loader: systemdBoot and secureBoot are mutually exclusive configurations.";
        }
      ];
    }

    # Standard Bootloader
    (lib.mkIf cfg.loader.systemdBoot.enable {
      boot.loader.systemd-boot.enable = true;
    })

    # EFI variables
    (lib.mkIf (cfg.loader.systemdBoot.enable || cfg.loader.secureBoot.enable) {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.timeout = 0;
    })

    # Lanzaboote - secure boot
    (lib.mkIf cfg.loader.secureBoot.enable {
      environment.systemPackages = with pkgs; [ sbctl ];
      
      # Force systemd-boot off to let Lanzaboote take over
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        # autoGenerateKeys.enable = true;
        # autoEnrollKeys.enable = true;
        pkiBundle = if impermanenceEnabled then "/persist/var/lib/sbctl" else "/var/lib/sbctl";
        configurationLimit = 12;
      };

      # Impermanence mapping for secure boot keys
      environment.persistence."/persist" = lib.mkIf impermanenceEnabled {
        directories = [ "/var/lib/sbctl" ];
      };
    })

    # Early systemd
    (lib.mkIf cfg.earlySystemd.enable {
      boot.initrd = { 
        systemd.enable = true;
        kernelModules = [ "tpm_tis" ]; # Needed for TPM autounlock
      };     
    })
  ];
}
