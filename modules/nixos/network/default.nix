{ config, lib, ... }:

let
  cfg = config.eira.system.network;
in {
  options.eira.system.network = {
    enable = lib.mkEnableOption "Base network daemon and sysctl hardening";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      dhcpcd.enable = false;
      useDHCP = false;
      useNetworkd = true;
    };

    systemd.network = {
      enable = true;

      networks."20-ethernet" = {
        matchConfig.Name = "e*";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };

      networks."20-wifi" = {
        matchConfig.Name = "w*";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 1; 
      "net.ipv4.conf.default.rp_filter" = 1; 

      "net.ipv4.conf.all.accept_redirects" = 0; 
      "net.ipv4.conf.default.accept_redirects" = 0; 

      "net.ipv4.conf.all.send_redirects" = 0; 
      "net.ipv4.conf.default.send_redirects" = 0; 

      "net.ipv4.conf.all.accept_source_route" = 0; 
      "net.ipv4.conf.default.accept_source_route" = 0;
    };
  };
}
