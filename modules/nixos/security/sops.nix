{ inputs, config, lib, ... }:

let
  cfg = config.eira.system.security.sops;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.eira.system.security.sops = {
    enable = lib.mkEnableOption "SOPS-Nix module";

    defaultSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the default encrypted secrets file.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.age.sshKeyPaths = if (config.eira.system.security.impermanence.enable or false)
      then [ "/persist/etc/ssh/ssh_host_ed25519_key" ] 
      else [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.defaultSopsFile = cfg.defaultSecretFile;
  };
}
