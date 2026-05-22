{ config, lib, osConfig, ... }:

let
  cfg = config.eira.home.programs.bash;

  sysBash = (osConfig.options.programs.bash.enable or null) != null;
  bashEnabled = hasNixosSteam && osConfig.programs.bash.enable;
in {
  options.eira.home.programs.bash = {
    enable = lib.mkEnableOption "Bash shell configuration and prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.bash = lib.mkIf bashEnabled {
      enable = true;
      initExtra = ''
        PS1='\n\[\e[31m\][\[\e[33m\]\u\[\e[32m\]@\[\e[34m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[31m\]]\[\e[0m\]\\$ '
      '';
    };
  };
}
