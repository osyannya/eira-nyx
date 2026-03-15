{ inputs, config, pkgs, ... }:

{
  imports = [
    ./modules.nix
  ];

  # Identity
  home = {
    username = "mriya";
    homeDirectory = "/home/mriya";
    stateVersion = "25.05";
  };

  # Persistence
  home.persistence."/persist" = {
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
      { directory = ".local/share/keyrings"; mode = "0700"; }
      ".local/state"
      ".mozilla"
        ".pki"
        ".steam"
    ];
    files = [
      { file = ".ssh/id_ed25519"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
      { file = ".ssh/id_ed25519.pub"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
    ];
  };
}
