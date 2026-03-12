{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
          vim-nix
        ];
        opt = [ ];
      };

      customRC = ''
        syntax on
        set number
        set relativenumber
        set cursorline
        set termguicolors&
        colorscheme default
      '';
    };
  };
}
