{ config, lib, pkgs, username, inputs, ... }:

{
  # Flakes
  nix = { 
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.auto-optimise-store = true;
    settings.trusted-users = [ username ];
  };

  # Unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      unstable = import inputs.nixpkgs-unstable {
        system = super.system;
        config = super.config; # Inherit allowUnfree, etc.
      };
    })
  ];
}

# get rid of unfree packages
