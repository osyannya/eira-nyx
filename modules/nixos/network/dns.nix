{ config, lib, ... }:

let
  cfg = config.eira.system.network.dns;
in {
  options.eira.system.network.dns = {
    enable = lib.mkEnableOption "Secure DNS resolution and stub-listener caching";
  };

  config = lib.mkIf cfg.enable {
    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [ "9.9.9.9" "45.90.28.0" ];
      extraConfig = ''
        DNS=1.1.1.1
        DNSStubListener=yes
        DNSStubListenerExtra=
        Cache=yes
      '';
    };

    networking.nameservers = lib.mkForce [ ];

    # Dynamic firewall rules for DNS
    networking.nftables.ruleset = lib.mkIf (config.networking.nftables.enable or false) ''
      table inet filter {
        set allowed_dns {
          type ipv4_addr; flags interval
          elements = { 1.1.1.1, 9.9.9.9, 45.90.28.0/24 }
        }
        set allowed_dns6 {
          type ipv6_addr; flags interval
          elements = { 2606:4700:4700::1111, 2606:4700:4700::1001, 2620:fe::9, 2620:fe::fe, 2a07:a8c0::/29 }
        }
        
        chain output {
          oifname "e*" ip daddr @allowed_dns udp dport 53 accept
          oifname "e*" ip daddr @allowed_dns tcp dport { 53, 853 } accept
          oifname "w*" ip daddr @allowed_dns udp dport 53 accept
          oifname "w*" ip daddr @allowed_dns tcp dport { 53, 853 } accept

          oifname "e*" ip6 daddr @allowed_dns6 udp dport 53 accept
          oifname "e*" ip6 daddr @allowed_dns6 tcp dport { 53, 853 } accept
          oifname "w*" ip6 daddr @allowed_dns6 udp dport 53 accept
          oifname "w*" ip6 daddr @allowed_dns6 tcp dport { 53, 853 } accept
        }
      }
    '';
  };
}
