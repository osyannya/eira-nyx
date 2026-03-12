{ config, lib, pkgs, ... }:

{
  programs.keepassxc = {
    enable = true;
    package = pkgs.keepassxc;
    autostart = true;
    # settings = {
      # FdoSecrets.Enabled = true; # Enabled manually, caused config errors
    # };
  };
}
