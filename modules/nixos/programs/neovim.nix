{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ripgrep ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
          vim-nix
          plenary-nvim
          nvim-web-devicons
          nvim-tree-lua
          bufferline-nvim
          telescope-nvim
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

        set mouse=a
        set incsearch
        set hlsearch

        lua << EOF
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        require("nvim-web-devicons").setup()
        
        require("nvim-tree").setup({
          view = { width = 30 },
          filters = { dotfiles = false },
        })
        
        require("bufferline").setup({
          options = {
            offsets = {{ filetype = "NvimTree", text = "File Explorer", padding = 1 }},
          }
        })
        
        require("telescope").setup()

        vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
        vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
        vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {})
        vim.keymap.set('n', '<leader>fz', require('telescope.builtin').current_buffer_fuzzy_find, {})
        EOF
      '';
    };
  };
}
