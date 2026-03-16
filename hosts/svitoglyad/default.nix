{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # Update
    ./modules.nix
    ./disko.nix
  ];

  # Identity
  networking.hostName = "svitoglyad";
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "25.05"; # Do not change

  # Environment
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

  environment.persistence."/persist" = {
    enable = true;
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/sbctl"
      "/var/lib/systemd"
      "/var/log"
    ];
    files = [
      { file = "/etc/machine-id"; parentDirectory = { mode = "0644"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = { mode = "u=rwx,g=rx,o=rx"; }; }
    ];
  };

  # Groups
  users.groups.network = {}; # Network secrets

  # Users
  users.mutableUsers = false;
  users.users.root = {
    hashedPasswordFile = config.age.secrets.rootPassword.path;
  };

  users.users.mriya = {
    isNormalUser = true;
    createHome = true;
    home = "/home/mriya";
    extraGroups = [ "audio" "network" "video" "wheel" "kvm" ];
    hashedPasswordFile = config.age.secrets.mriyaPassword.path;
  };

  # Home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      mriya = import ../../users/mriya/default.nix;
    };
  };

  # Secrets
  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/home/mriya/.ssh/id_ed25519"
  ];

  age.secrets = {
    rootPassword = {
      file = "${inputs.self}/hosts/svitoglyad/secrets/root-password.age";
      owner = "root";
      mode = "0400";
    };
    mriyaPassword = {
      file = "${inputs.self}/users/mriya/secrets/password.age";
      owner = "root";
      mode = "0400";
    };
    networks = {
      file = "${inputs.self}/secrets/shared/networks.age";
      group = "network";
      mode = "0440";
    };
  };
}
