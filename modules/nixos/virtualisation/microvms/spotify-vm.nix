{ inputs, pkgs, lib, ... }:

{
  microvm.vms.spotify = {
    config = { config, pkgs, ... }:

    {
      microvm = {
        hypervisor = "qemu";
        mem = 2560;
        vcpu = 2;

        interfaces = [{
          type = "user";
          id = "spotify-usernet";
          mac = "02:00:00:00:01:01";
        }];

        volumes = [{
          mountPoint = "/var";
          image = "/var/lib/microvms/spotify/var.img";
          size = 8192;
        }];

        shares = [
          {
            tag = "pipewire-socket";
            source = "/run/user/1000/pipewire-0";
            mountPoint = "/run/pipewire-host";
            proto = "virtiofs";
            readOnly = false;
          }
          {
            tag = "waypipe-socket";
            source = "/run/user/1000/waypipe";
            mountPoint = "/run/waypipe-host";
            proto = "virtiofs";
            readOnly = false;
          }
          {
            tag = "spotify-config";
            source = "/persist/microvms/spotify";
            mountPoint = "/home/spotify/.config/spotify";
            proto = "virtiofs";
            readOnly = false;
          }
        ];
      };

      system.stateVersion = "25.05";

      networking.useNetworkd = true;
      networking.useDHCP = false;

      systemd.network = {
        enable = true;
        networks."10-eth" = {
          matchConfig.Name = "eth* en*";
          networkConfig.DHCP = "yes";
        };
      };

      users.users.spotify = {
        isNormalUser = true;
        uid = 1500;
        home = "/home/spotify";
        createHome = true;
        extraGroups = [ "audio" "video" ];
      };

      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        extraConfig.pipewire."10-host-socket" = {
          "context.properties" = {
            "core.remote" = "unix:/run/pipewire-host/pipewire-0";
          };
        };
      };

      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [ waypipe spotify ];

      systemd.services.waypipe-client = {
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig = {
          User = "spotify";
          ExecStart = "${pkgs.waypipe}/bin/waypipe "
                    + "--socket /run/waypipe-host/waypipe.sock client";
          Restart = "on-failure";
        };
      };

      systemd.services.spotify = {
        wantedBy = [ "multi-user.target" ];
        after = [ "waypipe-client.service"
                  "pipewire.service"
                  "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          User = "spotify";
          ExecStart = "${pkgs.spotify}/bin/spotify";
          Restart = "on-failure";
          Environment = [
            "PIPEWIRE_RUNTIME_DIR=/run/pipewire-host"
            "WAYLAND_DISPLAY=wayland-0"
          ];
        };
      };
    };
  };
}
