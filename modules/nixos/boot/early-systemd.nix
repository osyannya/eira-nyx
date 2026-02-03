{ config, lib, ... }:

{
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultRestartSec = "2s";
    LogLevel = "warning";
  };

  boot.resumeDevice = "/dev/disk/by-label/swap";
}
