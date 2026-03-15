{
  description = "eira-nyx configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # Update manually
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      mkSystem = { hostPath, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModules.impermanence
            inputs.agenix.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            inputs.microvm.nixosModules.host
            home-manager.nixosModules.home-manager
            hostPath
          ];
        };
    in {
      nixosConfigurations = {
        legion5 = mkSystem { hostPath = ./hosts/legion5; };
        svitoglyad = mkSystem { hostPath = ./hosts/svitoglyad; };
        solace = mkSystem { hostPath = ./hosts/solace; }; # For different architecture: system = "aarch64-linux";
      };
    };
}
