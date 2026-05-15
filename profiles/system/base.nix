{ lib, ... }:

{
  time.timeZone = lib.mkDefault "America/Toronto";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Declarative users
  users = {
    mutableUsers = false;
    users.root.hashedPassword = lib.mkDefault "!"; # Lock root account
  };

  # Programs
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
    };
  };

  programs.nano = {
    enable = true;
    package = pkgs.nano;
    syntaxHighlight = true;
  };

  programs.tmux = { 
    enable = true;
  };

  programs.vim = {
    enable = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    gptfdisk
    parted
    pciutils
    usbutils
    procps
    rsync
    zip
    unzip
    p7zip
    gnutar
    file
    tree
    iproute2
    curl
    wget
    openssl
  ];

  # Unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # Services
  services.dbus = {
    enable = true;
    implementation = "broker"; # Default: dbus-daemon
  };

  services.getty = {
    autologinUser = null;
    helpLine = "";
  };

  environment.etc."issue".text = ''
    \e[32mWelcome to \e[35m\n\e[37m. System ready. Choose wisely.\e[0m
  '';

  security.polkit.enable = true;

  # Kernel hardening
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
    "kernel.unprivileged_bpf_disabled" = 1; # Disable unprivileged eBPF

    # Filesystem protection 
    "fs.protected_fifos" = 2; 
    "fs.protected_regular" = 2; 
    "fs.protected_symlinks" = 1; 
    "fs.protected_hardlinks" = 1;
  };

  # Universal binary cache
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;

      substituters = [
        "https://cache.nixos.org" # The official NixOS cache
        "https://nix-community.cachix.org" # Needed for Lanzaboote, Disko, NixOS-Anywhere
        "https://microvm.cachix.org" # Needed for MicroVM.nix
        "https://mic92.cachix.org" # Needed for SOPS-Nix
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # Update manually
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
        "mic92.cachix.org-1:CMPnNIGRphVhSfBWZeOzaVeaRVEEcrjBEnXoA7H0yEw="
      ];
    };
  };
}
