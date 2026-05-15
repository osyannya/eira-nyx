{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.programs.networkDiagnostics;
  sysCfg = config.eira.system;

  # Safely load the registry if there are tags to process
  registry = if (builtins.length cfg.allowedTags > 0 || builtins.length sysCfg.activeTags > 0)
    then builtins.fromJSON (builtins.readFile ../../../secrets/users.json)
    else {};

  # Resolve which users are allowed by this module via Tags
  moduleTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag cfg.allowedTags) (data.tags or [])
  ) registry);
  moduleAllowedMaster = lib.unique (moduleTaggedUsers ++ cfg.allowedUsers);

  # Resolve which users are actually active on the Host
  hostTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag sysCfg.activeTags) (data.tags or [])
  ) registry);
  hostActiveMaster = lib.unique (hostTaggedUsers ++ sysCfg.activeUsers);

in {
  options.eira.system.programs.networkDiagnostics = {
    enable = lib.mkEnableOption "Network diagnostic tools (MTR, TCPDump, Wireshark)";
    
    allowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of explicit users authorized to sniff packets via wireshark group";
    };

    allowedTags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of user tags authorized to sniff packets via wireshark group";
    };
  };

  config = lib.mkIf cfg.enable {
    # Base network tools
    programs.mtr.enable = true;
    programs.tcpdump.enable = true;

    # Wireshark with raw socket capabilities
    programs.wireshark = {
      enable = true;
      dumpcap.enable = true;
      package = pkgs.wireshark;
      usbmon.enable = false;
    };

    # Identity routing for packet sniffing privileges
    users.users = lib.mkMerge [
      # Loop over allowed users, apply group if they are active on this host
      (lib.genAttrs moduleAllowedMaster (userName: {
        extraGroups = lib.mkIf (builtins.elem userName hostActiveMaster) [ "wireshark" ];
      }))
      
      # Primary admin always gets access if the module is active
      {
        mriya = lib.mkIf (lib.attrByPath [ "eira" "system" "users" "mriya" "enable" ] false config) {
          extraGroups = [ "wireshark" ];
        };
      }
    ];
  };
}
