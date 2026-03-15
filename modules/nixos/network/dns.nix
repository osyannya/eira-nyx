{ config, lib, pkgs, ... }:

{
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
}
