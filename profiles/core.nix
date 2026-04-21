{ inputs, ... }: 

{
  nix.settings = {
    substituters = [ "https://eira-nyx.cachix.org" ];
    trusted-public-keys = [ "eira-nyx.cachix.org-1:YOUR_PUBLIC_KEY_HERE=" ];
  };

  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.microvm.nixosModules.host
    inputs.home-manager.nixosModules.home-manager
  ];
}
