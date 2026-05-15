{ config, lib, inputs, ... }:

let
  cfg = config.eira.system.features.overlays;
in {
  options.eira.system.features.overlays = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Overlays";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (self: super: {
        unstable = import inputs.nixpkgs-unstable {
          system = super.system;
          config = super.config; # Inherit allowUnfree
        };
      })
    ];
  };
}
