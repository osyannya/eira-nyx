{ config, lib, pkgs, ... }:

let
  cfg = config.eira.home.programs.neovim;

  hasImpermanence = (config.options.eira.home.security.impermanence.enable or null) != null;
  impermanenceEnabled = hasImpermanence && config.eira.home.security.impermanence.enable;
in {
  options.eira.home.programs.neovim = {
    enable = lib.mkEnableOption "Neovim editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ripgrep ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [ 
        vim-nix
        plenary-nvim
        nvim-web-devicons
        nvim-tree-lua
        bufferline-nvim
        telescope-nvim
      ];

      extraConfig = ''
        syntax on
        set number
        set relativenumber
        set cursorline

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

    home.persistence."/persist" = lib.mkIf impermanenceEnabled {
      directories = [ 
        ".local/share/nvim" 
        ".local/state/nvim" 
      ];
    };
  };
}
