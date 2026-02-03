{ config, lib, pkgs, ... }:

let
  qemuIface = "virbr0"; # Default interface used by libvirt virtual networks
in {
    networking.firewall = {
      enable = false; # nftables

      # Open ports in the firewall
      # allowedTCPPorts = [ ];
      # allowedUDPPorts = [ ];
    };

  networking.nftables.enable = true;

  networking.nftables.ruleset = ''
    flush ruleset;

    define qemu_iface = "${qemuIface}";

    table inet filter {
      chain input {
        type filter hook input priority filter; policy drop;

        ct state established,related accept;

        iifname "lo" accept comment "allow loopback";
        iifname $qemu_iface accept comment "allow qemu";

        tcp dport { 80, 443 } accept comment "allow http/https";
        udp dport 67 udp sport 68 accept comment "allow DHCP client";
        tcp dport 22 accept comment "allow ssh";

        counter drop;
      }

      chain forward {
        type filter hook forward priority filter; policy drop;

        ct state established,related accept;

        iifname $qemu_iface accept comment "forward qemu input";
        oifname $qemu_iface accept comment "forward qemu output";

        counter drop;
      }
    }

    table ip nat {
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.1.1.0/24 masquerade;
      }
    }
  '';

  # systemd.services.nftables-load = {
    # wantedBy = [ "network-pre.target" ];
    # before   = [ "network.target" ];
  # };
}
