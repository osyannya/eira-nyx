{ config, lib, ... }:

let
  cfg = config.eira.system.network.firewall;
  sysCfg = config.eira.system;

  registry = if (
    builtins.length cfg.bypassTags > 0 || builtins.length cfg.bypassUsers > 0 || 
    builtins.length cfg.offlineTags > 0 || builtins.length cfg.offlineUsers > 0 || 
    builtins.length sysCfg.activeTags > 0
  )
    then builtins.fromJSON (builtins.readFile ../../../secrets/users.json) 
    else {};

  # Host active users resolution
  hostTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag sysCfg.activeTags) (data.tags or [])
  ) registry);
  hostActiveMaster = lib.unique (hostTaggedUsers ++ sysCfg.activeUsers);

  # Bypass logic
  bypassTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag cfg.bypassTags) (data.tags or [])
  ) registry);
  bypassMaster = lib.unique (bypassTaggedUsers ++ cfg.bypassUsers);
  finalBypassUsers = builtins.filter (u: builtins.elem u hostActiveMaster) bypassMaster;
  
  bypassUIDs = map (u: toString (registry.${u} or {uid = 9999;}).uid) finalBypassUsers;
  bypassRule = lib.optionalString (builtins.length bypassUIDs > 0) 
    "meta skuid { ${lib.concatStringsSep ", " bypassUIDs} } accept";

  # Offline logic
  offlineTaggedUsers = lib.attrNames (lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag cfg.offlineTags) (data.tags or [])
  ) registry);
  offlineMaster = lib.unique (offlineTaggedUsers ++ cfg.offlineUsers);
  finalOfflineUsers = builtins.filter (u: builtins.elem u hostActiveMaster) offlineMaster;

  offlineUIDs = map (u: toString (registry.${u} or {uid = 9999;}).uid) finalOfflineUsers;
  offlineRule = lib.optionalString (builtins.length offlineUIDs > 0) 
    "meta skuid { ${lib.concatStringsSep ", " offlineUIDs} } drop";

in {
  options.eira.system.network.firewall = {
    enable = lib.mkEnableOption "Strict baseline nftables firewall";
    
    bypassUsers = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    bypassTags = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    
    offlineUsers = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    offlineTags = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = false;

    networking.nftables = {
      enable = true;
      ruleset = lib.mkBefore ''
        flush ruleset

        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iif "lo" accept
            ct state established,related accept

            iifname "e*" udp sport 67 udp dport 68 accept 
            iifname "w*" udp sport 67 udp dport 68 accept

            ip protocol icmp icmp type { destination-unreachable, time-exceeded, parameter-problem } accept
            ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-router-solicit, nd-neighbor-advert, nd-neighbor-solicit } accept
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
            ct state established,related accept
          }

          chain output {
            type filter hook output priority 0; policy drop;

            oif "lo" accept
            ct state established,related accept

            # Dynamic bypass and offline rules
            ${offlineRule}
            ${bypassRule}
            ${lib.optionalString (lib.attrByPath [ "eira" "system" "users" "mriya" "enable" ] false config) "meta skuid 1000 accept"}

            oifname "e*" udp dport 67 accept 
            oifname "w*" udp dport 67 accept 

            oifname "e*" tcp dport { 80, 443 } accept 
            oifname "e*" udp dport 443 accept
            oifname "w*" tcp dport { 80, 443 } accept 
            oifname "w*" udp dport 443 accept 

            oifname "e*" udp dport 123 accept 
            oifname "w*" udp dport 123 accept

            oifname { "e*", "w*" } ip protocol icmp icmp type echo-request accept
            oifname { "e*", "w*" } ip6 nexthdr icmpv6 icmpv6 type echo-request accept
          }
        }
      '';
    };
  };
}
