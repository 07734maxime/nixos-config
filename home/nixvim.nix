{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.tokyonight = {
      enable = true;
      settings = {
        transparent = true;
      };
    };

    globals.mapleader = " ";

    extraPlugins = [pkgs.vimPlugins.cord-nvim];

    extraConfigLua = ''
      require("cord").setup({
        editor = {
          client = "neovim",
          tooltip = "The Superior Text Editor",
        },
        display = {
          show_time = true,
          show_repository = true,
          show_cursor_position = false,
        },
        timer = {
          interval = 1500,
          reset_on_idle = false,
          reset_on_change = false,
        },
      })

    '';

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

    plugins = {
      lualine.enable = true;
      bufferline.enable = true;
      web-devicons.enable = true;
      indent-blankline.enable = true;
      which-key.enable = true;
      notify.enable = true;

      neo-tree = {
        enable = true;
        settings = {
          window.width = 30;
        };
      };

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

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      gitsigns.enable = true;

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

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua_ls.enable = true;
        };
      };

      conform-nvim = {
        enable = true;
        settings.formatters_by_ft = {
          nix = ["alejandra"];
          python = ["black"];
        };
      };

      comment.enable = true;
      autoclose.enable = true;
      trouble.enable = true;
      todo-comments.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
      }

      {
        mode = "n";
        key = "<leader>cf";
        action.__raw = ''
          function()
          		require("conform").format({ lsp_fallback = true })
          end
        '';
        options.desc = "Formater le fichier";
      }
    ];
  };
}
