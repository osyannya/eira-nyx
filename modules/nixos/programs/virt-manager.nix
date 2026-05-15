{ config, lib, ... }:

let
  cfg = config.eira.system.programs.virt-manager;
in {
  options.eira.system.programs.virt-manager = {
    enable = lib.mkEnableOption "Virtual Machine GUI manager";
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;
  };
}
