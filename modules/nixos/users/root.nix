{ config, lib, ... }:

let
  cfg = config.eira.system.users.root;

  hasSops = config.options.eira.system.security.sops.enable or null != null;
  sopsEnabled = hasSops && config.eira.system.security.sops.enable;
in {
  options.eira.system.users.root = {
    enable = lib.mkEnableOption "Declarative SOPS password mapping for the root account";
  };

  config = lib.mkIf cfg.enable {
    users.users.root = {
      hashedPasswordFile = lib.mkIf sopsEnabled config.sops.secrets."passwords/root".path;
    };
  };
}
