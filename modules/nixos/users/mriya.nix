{ config, lib, ... }:

let
  cfg = config.eira.system.users.mriya;
  sopsEnabled = config.eira.system.security.sops.enable or false;
  globalHmEnabled = config.eira.system.features.home-manager.enable;
in {
  options.eira.system.users.mriya = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true; # Enabled by default across the machines
      description = "Enable the primary mriya user account";
    };
    
    home-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Inject Home Manager dotfiles if the global engine is enabled";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.mriya = {
      isNormalUser = true;
      createHome = true;
      home = "/home/mriya";
      extraGroups = [ "wheel" ];
      
      # Map the password file if SOPS is actually enabled globally
      hashedPasswordFile = lib.mkIf sopsEnabled config.sops.secrets."passwords/mriya".path;
    };

    # Home Manager Intersection Logic
    home-manager.users.mriya = lib.mkIf (globalHmEnabled && cfg.home-manager.enable) (
      import ../../../profiles/users/mixin.nix 
    );
  };
}
