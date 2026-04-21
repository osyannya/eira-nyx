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

      ".config/BraveSoftware"
      ".config/fcitx"
      ".config/fcitx5"
      ".config/GIMP"
      ".config/Joplin" # Chromium cache
      ".config/joplin-desktop" # Actual application
      ".config/keepassxc"
      ".config/libreoffice"
      ".config/mozc"
      ".config/obs-studio"
      ".config/qalculate"
      ".config/qBittorrent"
      ".config/Signal"
      ".config/spotify"
      ".config/VSCodium"
      ".config/wireshark"

      ".librewolf"

      ".local/share/lutris"
      ".local/share/nvim"
      ".local/share/org.localsend.localsend_app"
      ".local/share/PrismLauncher"
      ".local/share/qalculate"
      ".local/share/qBittorrent"
      ".local/share/Steam"
      ".local/share/Terraria"

      # { directory = ".local/share/keyrings"; mode = "0700"; }

      ".local/state/nvim"
      ".local/state/wireplumber"

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
