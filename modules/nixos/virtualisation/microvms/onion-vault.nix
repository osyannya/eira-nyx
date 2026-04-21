{ config, pkgs, lib, ... }:

{
  microvm.vms."onion-vault" = {
    autostart = false;

    config = {
      # Guest OS Base
      system.stateVersion = "25.05";
      networking.hostName = "onion-vault";

      # Hypervisor & Hardware
      microvm = { 
        hypervisor = "qemu";
        shares = lib.mkForce [ ];
        vcpu = 2;
        mem = 512;

        volumes = [
          {
            mountPoint = "/"; 
            image = "/persist/var/lib/microvms/onion-vault.qcow2";
            size = 8192;
          }
        ];

        interfaces = [
          {
            type = "user";
            id = "eth0";
            mac = "02:00:00:00:00:01";
          }
        ];

        # Required for SSH access from the host
        forwardPorts = [
          { from = "host"; host.port = 2222; guest.port = 22; }
        ];
      };

      # Networking & Firewall
      networking.firewall.allowedTCPPorts = [ 22 8080 ];

      # Tor Hidden Service
      services.tor = {
        enable = true;
        client.enable = false; 
        settings = {
          HiddenServiceDir = "/var/lib/tor/onion_service/";
          HiddenServicePort = "80 127.0.0.1:8080";
        };
      };

      # Caddy web server
      services.caddy = {
        enable = true;
        globalConfig = ''
          admin off
        '';
        virtualHosts."http://:8080".extraConfig = ''
          root * /var/lib/vault_data
          file_server browse
        '';
      };

      # SSH / SFTP Access
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.PermitRootLogin = "no";
      };

      users.users.anonymous = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMx1MyouncnIuo1Yu7M/KTaK8UB7c++UxrAlANXHykcA anonymous@onion-vault" 
        ];
      };

      security.sudo.wheelNeedsPassword = false;

      # Data Directory Provisioning
      systemd.tmpfiles.rules = [
        "d /var/lib/vault_data 0755 anonymous wheel -"
      ];
    };
  };

  systemd.services."microvm@onion-vault" = {
    serviceConfig = {
      Group = "microvms";
      SupplementaryGroups = [ "nofirewall" ];
    };
  };
}
