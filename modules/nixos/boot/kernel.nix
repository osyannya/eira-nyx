{ config, lib, ... }:

{
  boot.kernelParams = [
    "loglevel=5"
    "systemd.log_level=info"
    "systemd.show_status=auto"
  ];

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
  };
}

# Black list kernel modules (does not improve boot speed)
