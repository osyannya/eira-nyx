{ config, lib, ... }:

{
  services.logind.settings.Login = {
    HandleSuspendKey = "hibernate";
    HandleLidSwitch = "suspend";
  };
}
