{ inputs, pkgs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ../../roles/workstation.nix
  ];

  # Identity
  networking.hostName = "svitoglyad";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05"; 

  # Deployment metadata
  deployment = {
    targetHost = "192.168.1.50";
    targetUser = "root";
    tags = [ "workstation" ];
  };

  # Time
  time.timeZone = "Europe/Kyiv";

  eira = {
    system = {
      desktop = {
        compositor.sway.enable = true;
      };
      programs = {
        localsend.enable = true;
        network-diagnostics.enable = true;
        pentesting.enable = true;
        steam.enable = true;
      };
      services = {
        btrfs-lifecycle = {
          enable = true;
          rootDevice = "/dev/nvme0n1p2"; 
        };
      };
      users = {
        dynamicUsers.enable = false;
      };
      video = {
        intel.enable = true;
      };
      virtualisation = {
        microvm.enable = true;
        microvms = {
          onion-vault.enable = true;
        };
      };
    };
  };
}
