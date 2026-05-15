{ config, lib, ... }:

let
  cfg = config.eira.home.programs.ssh;
in {
  options.eira.home.programs.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
    };
  };
}
