{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.tokyonight.enable = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      updatetime = 250;
    };

    # --- Plugins "cœur" de LazyVim ---
    plugins = {
      # UI
      lualine.enable = true;
      bufferline.enable = true;
      web-devicons.enable = true;
      indent-blankline.enable = true;
      which-key.enable = true;
      notify.enable = true;

      # Explorateur de fichiers
      neo-tree = {
        enable = true;
				settings = {
					window.width = 30;
				};
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      # Treesitter
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # Git
      gitsigns.enable = true;

      # Complétion
      cmp = {
        enable = true;
        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
            {name = "luasnip";}
          ];
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;
      cmp-buffer.enable = true;
      luasnip.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true; # LSP pour Nix
          lua_ls.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;
          # ajoutez vos langages ici
        };
      };

      # Formatage / Linting (à la LazyVim: none-ls / conform)
      conform-nvim = {
        enable = true;
        settings.formatters_by_ft = {
          nix = ["alejandra"];
          python = ["black"];
        };
      };

      # Confort
      comment.enable = true;
      autoclose.enable = true;
      trouble.enable = true;
      todo-comments.enable = true;
    };

    # --- Raccourcis clavier globaux ---
    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>TroubleToggle<CR>";
      }
			 {
    mode = "n";
    key = "<leader>format";
    action = "function() require('conform').format({ lsp_fallback = true }) end";
    options.desc = "Formater le fichier";
  }
    ];
  };
}
