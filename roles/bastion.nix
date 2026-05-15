{ lib, ... }:

{
  eira = {
    system = {
      boot = {
        loader.secureBoot.enable = true;
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
        impermanence.enable = true;
        sops = {
          enable = true;
          defaultSecretFile = ../../secrets/bastion.yaml;
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
          activeTags = [ "all-engineers" ]; 
        };
      };
    };
  };
}
