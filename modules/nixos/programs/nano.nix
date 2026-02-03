{ config, lib, pkgs, ... }:

{
  programs.nano = {
    enable = true;
    package = pkgs.nano;
    syntaxHighlight = true;
  };
}
