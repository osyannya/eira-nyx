{ config, lib, ... }:

let
  cfg = config.eira.system.network.wireless;
  sysCfg = config.eira.system;

  registry = if (builtins.length cfg.allowedTags > 0 || builtins.length sysCfg.activeTags > 0)
    then builtins.fromJSON (builtins.readFile ../../../secrets/users.json) 
    else {};

  moduleTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag cfg.allowedTags) (data.tags or [])
  ) registry);
  moduleAllowedMaster = lib.unique (moduleTaggedUsers ++ cfg.allowedUsers);

  hostTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag sysCfg.activeTags) (data.tags or [])
  ) registry);
  hostActiveMaster = lib.unique (hostTaggedUsers ++ sysCfg.activeUsers);

in {
  options.eira.system.network.wireless = {
    enable = lib.mkEnableOption "Wireless supplicant configuration";
    
    allowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = []; 
      description = "List of explicit users authorized for the network group";
    };

    allowedTags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = []; 
      description = "List of user tags authorized for the network group";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager.enable = false;
      wireless = { 
        enable = true;
        userControlled = {
          enable = true;
          group = "network";
        };
        extraConfig = ''
          ap_scan=1
          passive_scan=1
          mac_addr=2
          preassoc_mac_addr=2
        '';
      };
    };

    users.users = lib.mkMerge [
      (lib.genAttrs moduleAllowedMaster (userName: {
        extraGroups = lib.mkIf (builtins.elem userName hostActiveMaster) [ "network" ];
      }))
      
      {
        mriya = lib.mkIf config.eira.system.users.mriya.enable {
          extraGroups = [ "network" ];
        };
      }
    ];
  };
}
