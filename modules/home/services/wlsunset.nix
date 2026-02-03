{ config, lib, pkgs, ... }:

{
  services.wlsunset = {
    enable = true;
    package = pkgs.wlsunset;
    sunrise = "08:00";
    sunset = "16:00";
  };
}
