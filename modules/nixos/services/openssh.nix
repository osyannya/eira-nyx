{ config, lib, ... }:

let
  cfg = config.eira.system.services.openssh;
  fwEnabled = config.eira.system.network.firewall.enable or false;
in {
  options.eira.system.services.openssh = {
    enable = lib.mkEnableOption "OpenSSH daemon";
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "Custom SSH port.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    # Standard NixOS firewall fallback
    networking.firewall.allowedTCPPorts = lib.mkIf (!fwEnabled) [ cfg.port ];

    # Dynamic injection into your custom nftables ruleset
    networking.nftables.ruleset = lib.mkIf fwEnabled ''
      table inet filter {
        chain input {
          ip protocol tcp tcp dport ${toString cfg.port} accept
          ip6 nexthdr tcp tcp dport ${toString cfg.port} accept
        }
        
        chain output {
          oifname "e*" tcp dport ${toString cfg.port} accept
          oifname "w*" tcp dport ${toString cfg.port} accept
        }
      }
    '';
  };
}
