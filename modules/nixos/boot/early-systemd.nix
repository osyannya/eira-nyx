{ config, lib, ... }:

{
  boot.initrd = { 
    systemd.enable = true;
    kernelModules = [ "tpm_tis" ];
  };

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultRestartSec = "2s";
    LogLevel = "debug";
  };

  boot.resumeDevice = "/dev/mapper/crypted";
}
