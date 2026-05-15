{ config, lib, inputs, ... }:

let
  cfg = config.eira.system.virtualisation.microvm;
in {
  imports = [
    inputs.microvm.nixosModules.host
  ];

  options.eira.system.virtualisation.microvm = {
    enable = lib.mkEnableOption "MicroVM host capabilities";
  };

  config = lib.mkIf cfg.enable {
    # microvm.host.enable = true; # If required by the microvm flake
  };
}
