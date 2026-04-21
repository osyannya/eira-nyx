{ config, pkgs, lib, ... }:

{
  networking.firewall.enable = false;

  networking.nftables = {
    enable = true;
    ruleset = ''
      flush ruleset

      table inet filter {

        set allowed_dns {
          type ipv4_addr
          flags interval
          elements = { 1.1.1.1, 9.9.9.9, 45.90.28.0/24 }
        }

        set allowed_dns6 {
          type ipv6_addr
          flags interval
          elements = {
            2606:4700:4700::1111,
            2606:4700:4700::1001,
            2620:fe::9,
            2620:fe::fe,
            2a07:a8c0::/29
           }
        }

        chain input {
          type filter hook input priority 0;
          policy drop;

          # Allow loopback
          iif "lo" accept

          # Allow only established traffic
          ct state established,related accept

          # Allow DHCP
          iifname "en*" udp sport 67 udp dport 68 accept 
          iifname "wl*" udp sport 67 udp dport 68 accept

          # Allow ping
          ip protocol icmp icmp type { 
            destination-unreachable, 
            time-exceeded, 
            parameter-problem 
          } accept

          # IPv6 rules
          ip6 nexthdr icmpv6 icmpv6 type {
            destination-unreachable,
            packet-too-big,
            time-exceeded,
            parameter-problem,
            nd-router-advert,
            nd-router-solicit,
            nd-neighbor-advert,
            nd-neighbor-solicit
          } accept

          # LocalSend
          iifname { "en*", "wl*" } tcp dport 53317 accept
          iifname { "en*", "wl*" } udp dport 53317 accept

          # VM ISOLATION INPUT RULES
          iifname "virbr0" udp dport { 53, 67 } accept
          iifname "virbr0" tcp dport 53 accept 
          iifname "virbr0" drop
        }

        chain forward {
          type filter hook forward priority 0;
          policy drop;

          # Allow only established traffic
          ct state established,related accept

          # VM ROUTING RULES
          iifname "virbr0" oifname { "en*", "wl*" } accept
      
          # Block VMs from talking to each other
          iifname "virbr0" oifname "virbr0" drop
        }

        chain output {
          type filter hook output priority 0;
          policy drop;

          # Allow loopback
          oif "lo" accept

          # Allow only established traffic
          ct state established,related accept

          # Allow DHCP 
          oifname "en*" udp dport 67 accept 
          oifname "wl*" udp dport 67 accept 

          # DNS & DNS-over-TLS 
          oifname "en*" ip daddr @allowed_dns udp dport 53 accept
          oifname "en*" ip daddr @allowed_dns tcp dport { 53, 853 } accept

          oifname "wl*" ip daddr @allowed_dns udp dport 53 accept
          oifname "wl*" ip daddr @allowed_dns tcp dport { 53, 853 } accept

          # IPv6 rules
          oifname "en*" ip6 daddr @allowed_dns6 udp dport 53 accept
          oifname "en*" ip6 daddr @allowed_dns6 tcp dport { 53, 853 } accept

          oifname "wl*" ip6 daddr @allowed_dns6 udp dport 53 accept
          oifname "wl*" ip6 daddr @allowed_dns6 tcp dport { 53, 853 } accept

          # Web 
          oifname "en*" tcp dport { 80, 443 } accept 
          oifname "en*" udp dport 443 accept

          oifname "wl*" tcp dport { 80, 443 } accept 
          oifname "wl*" udp dport 443 accept 

          # NTP 
          oifname "en*" udp dport 123 accept 
          oifname "wl*" udp dport 123 accept

          # Ping
          oifname { "en*", "wl*" } ip protocol icmp icmp type echo-request accept
          oifname { "en*", "wl*" } ip6 nexthdr icmpv6 icmpv6 type echo-request accept

          # Tracepath
          oifname { "en*", "wl*" } udp dport 33434-33534 accept

          # LocalSend
          oifname { "en*", "wl*" } tcp dport 53317 accept
          oifname { "en*", "wl*" } udp dport 53317 accept

          # Allow bypass firewall for Tor
          skgid 991 accept

          # Allow bypass firewall for proton VPN
          oifname { "en*", "wl*" } udp dport 51820 accept
          oifname "proton*" accept

          # HOST-TO-VM RULES
          oifname "virbr0" udp sport { 53, 67 } accept
          oifname "virbr0" tcp sport 53 accept
        }
      }
    '';
  };
}
