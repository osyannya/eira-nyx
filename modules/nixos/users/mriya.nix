{ config, lib, ... }:

let
  cfg = config.eira.system.users.mriya;

  hasSops = config.options.eira.system.security.sops.enable or null != null;
  sopsEnabled = hasSops && config.eira.system.security.sops.enable;

  hasHm = config.options.eira.system.features.home-manager.enable or null != null;
  globalHmEnabled = hasHm && config.eira.system.features.home-manager.enable;
in {
  options.eira.system.users.mriya = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the primary mriya user account";
    };
    
    home-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use Home Manager dotfiles if the global engine is enabled";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.mriya = {
      isNormalUser = true;
      createHome = true;
      home = "/home/mriya";
      extraGroups = [ "wheel" ];
      
      hashedPasswordFile = lib.mkIf sopsEnabled config.sops.secrets."passwords/mriya".path;
    };

    home-manager.users.mriya = lib.mkIf (globalHmEnabled && cfg.home-manager.enable) (
      import ../../../profiles/users/mixin.nix 
    );
  };
}
