{ lib, ... }:

{
  eira = {
    system = {
      boot = {
        loader.secureBoot.enable = true;
        earlySystemd.enable = true;
      };
      desktop = {
        fonts.enable = true;
        materials.enable = true;
      };
      features = {
        home-manager.enable = true;
        overlays.enable = true;
        stylix.enable = true;
        zram.enable = true;
      };
      network = {
        enable = true;
        dns.enable = true;
        firewall.enable = true;
        wireless.enable = true;
      };
      programs = {
        thunar.enable = true;
        virt-manager.enable = true;
      };
      security = {
        apparmor.enable = true;
        impermanence.enable = true;
        sops = {
          enable = true;
          defaultSecretFile = ../../secrets/workstation.yaml;
        };
      };
      services = {
        audio.enable = true;
        bluetooth.enable = true;
        openssh.enable = true;
        power.enable = true;
      };
      users = {
        mriya.enable = true;
        root.enable = true; # Skip?
        dynamicUsers = {
          enable = true;
          activeTags = [ "developer" "employee" ];
        };
      };
      virtualisation = {
        libvirtd.enable = true;
      };
    };
  };
}
