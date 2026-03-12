{ config, lib, ... }:

{
  # boot.kernelParams = [
    # [ 11.760423] Bluetooth: hci0: Reading supported features failed (-16)
  # ];

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;

    # Disable unprivileged eBPF
    "kernel.unprivileged_bpf_disabled" = 1;

    # Filesystem protection 
    "fs.protected_fifos" = 2; 
    "fs.protected_regular" = 2; 
    "fs.protected_symlinks" = 1; 
    "fs.protected_hardlinks" = 1;

    # Network 
    "net.ipv4.conf.all.rp_filter" = 1; 
    "net.ipv4.conf.default.rp_filter" = 1; 

    "net.ipv4.conf.all.accept_redirects" = 0; 
    "net.ipv4.conf.default.accept_redirects" = 0; 

    "net.ipv4.conf.all.send_redirects" = 0; 
    "net.ipv4.conf.default.send_redirects" = 0; 

    "net.ipv4.conf.all.accept_source_route" = 0; 
    "net.ipv4.conf.default.accept_source_route" = 0;

    # "kernel.modules_disabled" = 1;
  };
}
