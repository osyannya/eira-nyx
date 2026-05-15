{ config, lib, osConfig, ... }:

let
  cfg = config.eira.home.security.impermanence;
  sysImpermanence = osConfig.eira.system.security.impermanence.enable or false;
in {
  options.eira.home.security.impermanence = {
    enable = lib.mkEnableOption "Home manager impermanence";
  };

  config = lib.mkIf cfg.enable {
    home.persistence."/persist" = lib.mkIf sysImpermanence {
      allowOther = true;
      directories = [
        ".pki"
      ] ++ lib.optional (osConfig.eira.system.programs.networkDiagnostics.enable or false) ".config/wireshark"
        ++ lib.optional (osConfig.eira.system.programs.localsend.enable or false) ".local/share/org.localsend.localsend_app"
        ++ lib.optionals (osConfig.eira.system.programs.steam.enable or false) [ ".local/share/Steam" ".steam" ]
        ++ lib.optional (osConfig.eira.system.services.audio.enable or false) ".local/state/wireplumber";
    };
  };
}
