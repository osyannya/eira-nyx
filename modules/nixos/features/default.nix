{ inputs, ... }:

{
  # Flakes
  nix = { 
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;    
    };
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
