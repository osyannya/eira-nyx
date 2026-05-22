{ config, lib, ... }:

let
  cfg = config.eira.system.programs.steam;
in {
  options.eira.system.programs.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
