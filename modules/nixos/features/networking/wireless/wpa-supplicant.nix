{ config, lib, pkgs, ... }:

{
  networking = {
    networkmanager.enable = false; # Easiest to use and most distros use this by default.

    wireless = { 
      enable = true; # Enables wireless support via wpa_supplicant.

      userControlled = {
        enable = true;
        group = "network";
      };

      extraConfig = ''
        ap_scan=1
        passive_scan=1
	    mac_addr=2
        preassoc_mac_addr=2
      '';
    };
  };    
}
