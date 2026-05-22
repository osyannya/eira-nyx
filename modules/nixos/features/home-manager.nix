{ inputs, config, lib, ... }:

let
  cfg = config.eira.system.features.home-manager;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.eira.system.features.home-manager = {
    enable = lib.mkEnableOption "Home Manager module";
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      sharedModules = [ ../../home/default.nix ];
    };
  };
}
