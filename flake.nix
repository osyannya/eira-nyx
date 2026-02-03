{
  description = "Ultimate NixOS configuration";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # Update
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11"; # Update
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # stylix.url = "github:danth/stylix";
    # nix-colors.url = "github:misterio77/nix-colors";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    # sops-nix.url = "github:Mic92/sops-nix";

    impermanence.url = "github:nix-community/impermanence";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, agenix, impermanence, disko, ... }: {
    nixosConfigurations = {
      legion5 = let
        system = "x86_64-linux";
        username = "alva";

	specialArgs = {
	  inherit username;
	  inputs = inputs;
	};
      in  
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
	  modules = [
            ./hosts/legion5
	    # ./users/${username}/sshkeys.nix
            
	    home-manager.nixosModules.home-manager {
	      home-manager.useGlobalPkgs = true;
	      home-manager.useUserPackages = true;

	      home-manager.extraSpecialArgs = inputs // specialArgs;
	      home-manager.users.${username} = import ./users/${username}/default.nix;
            }

            # stylix.nixosModules.stylix
            # nix-colors.homeManagerModules.default

            agenix.nixosModules.default
            # sops.nixosModules.sops

            impermanence.nixosModules.impermanence

            disko.nixosModules.disko
	  ];
        }; 

      svitoglyad = let
        system = "x86_64-linux";
        username = "mriya";

        specialArgs = {
          inherit username;
          inputs = inputs;
	};
      in 
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
	  modules = [
            ./hosts/svitoglyad

            home-manager.nixosModules.home-manager {
	      home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

	      home-manager.extraSpecialArgs = inputs // specialArgs;
	      home-manager.users.${username} = import ./users/${username}/default.nix;
            }

            agenix.nixosModules.default

            impermanence.nixosModules.impermanence

            disko.nixosModules.disko
	  ];
        }; 
    };
  };
}
