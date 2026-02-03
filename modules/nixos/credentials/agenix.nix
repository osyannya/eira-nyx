{ config, lib, pkgs, inputs, username, ... }:

let
  host = config.networking.hostName;
in {
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/home/${username}/.ssh/id_ed25519"
  ];

  age.secrets = {
    rootPassword = {
      file = "${inputs.self}/modules/nixos/credentials/hosts/${host}/root-password.age";
      owner = "root";
      mode = "0400";
    };

    userPassword = {
      file = "${inputs.self}/modules/nixos/credentials/users/${username}/password.age";
      owner = "root";
      mode = "0400";
    };

    networks = {
      file = "${inputs.self}/modules/nixos/credentials/shared/networks.age";
      owner = username;
      group = "network";
      mode = "0400";
    };
  };

  # mkpasswd -m sha-512
  # agenix -e file.age
  users.users.root.hashedPasswordFile = config.age.secrets.rootPassword.path;
  users.users.${username}.hashedPasswordFile = config.age.secrets.userPassword.path;
}
