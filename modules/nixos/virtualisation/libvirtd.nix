{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.virtualisation.libvirtd;
  sysCfg = config.eira.system;

  # Safely load the registry if there are tags to process
  registry = if (builtins.length cfg.allowedTags > 0 || builtins.length sysCfg.activeTags > 0)
    then builtins.fromJSON (builtins.readFile ../../../secrets/users.json) # Change later 
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
  # API
  options.eira.system.virtualisation.libvirtd = {
    enable = lib.mkEnableOption "Libvirtd virtualization";
    
    allowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = []; 
      description = "List of explicit users authorized for libvirtd";
    };

    allowedTags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = []; 
      description = "List of user tags authorized for libvirtd";
    };
  };

  # Capability
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true; # Virtual tpm 2.0 support
      };
      allowedBridges = [ "virbr0" ];
    };

    # Identity routing
    users.users = lib.mkMerge [
      # Loop over users allowed by the module, check if they are active on the host
      (lib.genAttrs moduleAllowedMaster (userName: {
        extraGroups = lib.mkIf (builtins.elem userName hostActiveMaster) [ "libvirtd" "kvm" ];
      }))
      
      # Mriya always gets access if the user exists and the module is on
      {
        mriya = lib.mkIf (lib.attrByPath [ "eira" "system" "users" "mriya" "enable" ] false config) {
          extraGroups = [ "libvirtd" "kvm" ];
        };
      }
    ];

    # State mapping
    environment.persistence."/persist" = lib.mkIf (config.eira.system.security.impermanence.enable or false) {
      directories = [
        "/etc/libvirt"
        "/var/lib/libvirt"
      ] ++ lib.optional config.virtualisation.libvirtd.qemu.swtpm.enable "/var/lib/swtpm"; 
    };

    # If the host firewall is active add rules for VMs
    networking.nftables.ruleset = lib.mkIf (config.networking.nftables.enable or false) ''
      table inet filter {
        chain input {
          # VM ISOLATION INPUT RULES
          iifname "virbr0" udp dport { 53, 67 } accept
          iifname "virbr0" tcp dport 53 accept 
          iifname "virbr0" drop
        }

        chain forward {
          # VM ROUTING RULES
          iifname "virbr0" oifname { "e*", "w*" } accept
          
          # Block VMs from talking to each other
          iifname "virbr0" oifname "virbr0" drop
        }

        chain output {
          # HOST-TO-VM RULES
          oifname "virbr0" udp sport { 53, 67 } accept
          oifname "virbr0" tcp sport 53 accept
        }
      }
    '';
  };
}
