{ config, lib, pkgs, username, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = username;
        email = "12345678+${username}@users.noreply.github.com";
      };
    };
  };
}
