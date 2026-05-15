{ inputs }:

let
  inherit (inputs.nixpkgs) lib;

  hostsDir = ../hosts;

  hostEntries = builtins.readDir hostsDir;
  hostNames = builtins.filter 
    (name: hostEntries.${name} == "directory") 
    (builtins.attrNames hostEntries);

  mkHost = name: lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [  
      inputs.colmena.nixosModules.deploymentOptions # Colmena
      ../profiles/system/base.nix # base profile
      ../modules/nixos/default.nix # NixOS modules
      (hostsDir + "/${name}/default.nix") # hosts 
    ];
  };

in {
  # Generate the standard NixOS systems
  nixosConfigurations = builtins.listToAttrs (map (name: {
    inherit name;
    value = mkHost name;
  }) hostNames);  
}
