{ config, lib, osConfig ... }:

let
  cfg = config.eira.home.programs.bash;
  sysBash = osConfig.programs.bash.enable or false;
in {
  options.eira.home.programs.bash = {
    enable = lib.mkEnableOption "Bash shell configuration and prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.bash = lib.mkIf sysBash {
      enable = true;
      initExtra = ''
        PS1='\n\[\e[31m\][\[\e[33m\]\u\[\e[32m\]@\[\e[34m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[31m\]]\[\e[0m\]\\$ '
      '';
    };
  };
}
