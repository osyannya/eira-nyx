{ config, lib, pkgs, ... }:

{
  networking = {
    dhcpcd.enable = false; # Default true

    useDHCP = false; # Default true

    useNetworkd = true;
  };

  systemd.network = {
    enable = true;

    netdevs."10-br-lab" = {
      netdevConfig = {
        Name = "br-lab";
        Kind = "bridge";
      };
    };

    networks."10-br-lab" = {
      matchConfig = {
        Name = "br-lab";
      };

      networkConfig = {
        DHCP = "no";
        LinkLocalAddressing = "no";
        ConfigureWithoutCarrier = true;
      };
    };

    networks."20-ethernet" = {
      matchConfig.Name = "enp*";

      networkConfig = {
        DHCP = "yes";
        LinkLocalAddressing = "no";
      };
    };

    networks."20-wifi" = {
      matchConfig.Name = "wlp*";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
    };
  };

  services.resolved.enable = true;
}
