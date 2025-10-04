# home/todor/modules/nixvim/plugins.nix
{
  plugins = {
    # File explorer
    neo-tree = {
      enable = true;
      closeIfLastWindow = true;
      window = {
        width = 30;
      };
    };

    # Fuzzy finder
    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fb" = "buffers";
        "<leader>fh" = "help_tags";
      };
    };

    # Syntax highlighting
    treesitter = {
      enable = true;
      nixGrammars = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    # Auto completion
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
        ];
        mapping = {
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
      };
    };

    # LSP
    lsp = {
      enable = true;
      servers = {
        nil_ls.enable = true; # Nix
        lua_ls.enable = true; # Lua
        bashls.enable = true; # Bash
      };
      keymaps = {
        silent = true;
        diagnostic = {
          "<leader>cd" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };
        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gI" = "implementation";
          "gr" = "references";
          "K" = "hover";
          "<leader>ca" = "code_action";
          "<leader>cr" = "rename";
          "<leader>cf" = "format";
        };
      };
    };

    # Snippets
    luasnip.enable = true;

    # Status line
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "tokyonight";
        };
      };
    };

    # Web dev icons
    web-devicons.enable = true;

    # Git integration
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "+";
          change.text = "~";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
        };
      };
    };

    # Auto pairs
    nvim-autopairs.enable = true;

    # Indent guides
    indent-blankline = {
      enable = true;
      settings = {
        indent = {
          char = "│";
        };
        scope = {
          enabled = true;
        };
      };
    };

    # Comments
    comment.enable = true;

    # Which key
    which-key = {
      enable = true;
      settings = {
        spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "Split";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Tab";
          }
        ];
      };
    };
  };
}