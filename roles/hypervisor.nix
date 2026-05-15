{ lib, ... }:

{
  eira = {
    system = {
      boot = {
        loader.systemdBoot.enable = true;
        earlySystemd.enable = true;
      };
      features = {
        home-manager.enable = true;
        overlays.enable = true;
      };
      network = {
        enable = true;
        dns.enable = true;
        firewall.enable = true;
      };
      programs = {
        networkDiagnostics.enable = true;
      };
      security = {
        apparmor.enable = true;
        sops = {
          enable = true;
          defaultSecretFile = ../../secrets/hypervisor.yaml;
        };
      };
      services = {
        openssh.enable = true;
      };
      users = {
        mriya.enable = true;
        root.enable = true;
        dynamicUsers = {
          enable = true;
          activeTags = [ "infra-admin" ];
        };
      };
      virtualisation = {
        libvirtd.enable = true;
        microvm.enable = true;
      };
    };
  };
}
