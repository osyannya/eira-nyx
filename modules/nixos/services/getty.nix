{ config, lib, ... }:

{
  services.getty = {
    autologinUser = null;
    helpLine = "";
  };

  environment.etc."issue".text = ''
    \e[32mWelcome to \e[35m\n\e[37m. System ready. Choose wisely.\e[0m
  '';
}

