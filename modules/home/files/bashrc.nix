{ config, lib, pkgs, ... }:

{
  # Bash prompt
  home.file.".bashrc".text = ''
    PS1='\n\[\e[38;5;196m\][\[\e[38;5;220m\]\u\[\e[38;5;40m\]@\[\e[38;5;39m\]\h\[\e[0m\]:\[\e[38;5;219m\]\w\[\e[38;5;196m\]]\[\e[0m\]\\$ '
  '';
}
