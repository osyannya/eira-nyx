{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.programs.localsend;
in {
  options.eira.system.programs.localsend = {
    enable = lib.mkEnableOption "LocalSend cross-platform file sharing";
  };

  config = lib.mkIf cfg.enable {
    programs.localsend = {
      enable = true;
      package = pkgs.localsend;
    };

    # Dynamic Firewall Composability 
    networking.nftables.ruleset = lib.mkIf (config.networking.nftables.enable or false) ''
      table inet filter {
        chain input {
          iifname { "e*", "w*" } tcp dport 53317 accept
          iifname { "e*", "w*" } udp dport 53317 accept
        }

        chain output {
          oifname { "e*", "w*" } tcp dport 53317 accept
          oifname { "e*", "w*" } udp dport 53317 accept
        }
      }
    '';
  };
}

# add condition if home-manager is enabled, when impermanence is enabled system wide and in home, add home paths to persist
