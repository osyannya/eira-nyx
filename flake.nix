{
  description = "eira-nyx configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # Update manually
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11"; # Update manually
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0"; # Check later for updates
    microvm.url = "github:microvm-nix/microvm.nix";
    colmena.url = "github:zhaofengli/colmena";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs: import ./lib/mkFlake.nix { inherit inputs; };
}
