{ config, lib, osConfig, ... }:

let
  cfg = config.eira.home.security.impermanence;

  sysImpermanence = (osConfig.options.eira.system.security.impermanence.enable or null) != null; 
  impermanenceEnabled = sysImpermanence && osConfig.eira.system.security.impermanence.enable;

  hasWireshark = (osConfig.options.programs.wireshark.enable or null) != null;
  wiresharkEnabled = hasWireshark && osConfig.programs.wireshark.enable;

  hasLocalsend = (osConfig.options.programs.localsend.enable or null) != null;
  localsendEnabled = hasLocalsend && osConfig.programs.localsend.enable;

  hasSteam = (osConfig.options.programs.steam.enable or null) != null;
  steamEnabled = hasSteam && osConfig.programs.steam.enable;

  hasWireplumber = (osConfig.options.services.pipewire.wireplumber.enable or null) != null;
  wireplumberEnabled = hasWireplumber && osConfig.services.pipewire.wireplumber.enable;

  # Ensure the upstream Home Manager impermanence module schema is loaded before execution
  hasHmPersistence = (config.options.home.persistence or null) != null;
in {
  options.eira.home.security.impermanence = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = impermanenceEnabled; # Inherits system state by default; allows user-level override
      description = "Enable data-driven Home Manager user profile persistence mappings.";
    };
  };

  config = lib.mkIf (cfg.enable && impermanenceEnabled) {
    assertions = [
      {
        assertion = hasHmPersistence;
        message = "eira.home.security.impermanence: The upstream Home Manager impermanence module input is missing from the evaluation graph.";
      }
    ];

    home.persistence."/persist" = {
      allowOther = true;
      directories = [
        ".pki"
      ] ++ lib.optional wiresharkEnabled ".config/wireshark"
        ++ lib.optional localsendEnabled ".local/share/org.localsend.localsend_app"
        ++ lib.optionals steamEnabled [ ".local/share/Steam" ".steam" ]
        ++ lib.optional wireplumberEnabled ".local/state/wireplumber";
    };
  };
}
