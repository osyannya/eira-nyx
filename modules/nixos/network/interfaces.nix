{ ... }:

{
  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;

    networks."20-ethernet" = {
      matchConfig.Name = "en*";

      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };

      dhcpV4Config = {
        UseDNS = false;
      };

      dhcpV6Config = {
        UseDNS = false;
      };
    };

    networks."20-wifi" = {
      matchConfig.Name = "wl*";

      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };

      dhcpV4Config = {
        UseDNS = false;
      };

      dhcpV6Config = {
        UseDNS = false;
      };
    };
  };
}
