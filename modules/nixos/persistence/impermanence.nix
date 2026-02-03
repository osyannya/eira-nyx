{ config, lib, pkgs, username, ... }:

{
  # Move everything to persist before activating impermanence (rsync)
  environment.persistence."/persist" = {
    enable = true;
    directories = [
      "/etc/ssh"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"
    ];
    files = [
      { file = "/etc/machine-id"; parentDirectory = { mode = "0644"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "u=rw,g=,o="; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = { mode = "u=rw,g=r,o=r"; }; }
    ];

    users.${username} = {
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Public"
        "Templates"
        "Videos"

        "JoplinBackup"

        ".config"
        ".librewolf"
        ".local/share"
        # { directory = ".local/share/keyrings"; mode = "0700"; }
        ".local/state"
        ".mozilla"
        ".pki"
        ".ssh"
        ".steam"
      ];
      files = [
        { file = ".ssh/id_ed25519"; parentDirectory = { mode = "u=rw,g=,o="; }; }
        { file = ".ssh/id_ed25519.pub"; parentDirectory = { mode = "u=rw,g=r,o=r"; }; }
      ];
    };
  };
}
