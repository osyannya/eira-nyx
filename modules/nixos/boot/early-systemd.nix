{ config, lib, ... }:

{
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultRestartSec = "2s";
    LogLevel = "debug";
  };

  boot.resumeDevice = "/dev/mapper/crypted";
}
