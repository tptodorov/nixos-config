{
  lib,
  pkgs,
  standalone ? false,
  ...
}:
{
  programs.nixvim = lib.mkIf (!standalone) {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Global settings
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Editor options
    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Tabs and indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;

      # Line wrapping
      wrap = false;

      # Search settings
      ignorecase = true;
      smartcase = true;

      # Cursor line
      cursorline = true;

      # Appearance
      termguicolors = true;
      background = "dark";
      signcolumn = "yes";

      # Backspace
      backspace = "indent,eol,start";

      # Clipboard
      clipboard = "unnamedplus";

      # Split windows
      splitright = true;
      splitbelow = true;

      # Mouse
      mouse = "a";

      # File handling
      swapfile = false;
      backup = false;
      undofile = true;
    };

    # Key mappings
    keymaps = [
      # General keymaps
      {
        mode = "i";
        key = "jk";
        action = "<ESC>";
        options = {
          desc = "Exit insert mode with jk";
        };
      }
      {
        mode = "n";
        key = "<leader>nh";
        action = ":nohl<CR>";
        options = {
          desc = "Clear search highlights";
        };
      }

      # Increment/decrement numbers
      {
        mode = "n";
        key = "<leader>+";
        action = "<C-a>";
        options = {
          desc = "Increment number";
        };
      }
      {
        mode = "n";
        key = "<leader>-";
        action = "<C-x>";
        options = {
          desc = "Decrement number";
        };
      }

      # Window management
      {
        mode = "n";
        key = "<leader>sv";
        action = "<C-w>v";
        options = {
          desc = "Split window vertically";
        };
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<C-w>s";
        options = {
          desc = "Split window horizontally";
        };
      }
      {
        mode = "n";
        key = "<leader>se";
        action = "<C-w>=";
        options = {
          desc = "Make splits equal size";
        };
      }
      {
        mode = "n";
        key = "<leader>sx";
        action = "<cmd>close<CR>";
        options = {
          desc = "Close current split";
        };
      }

      # Tab management
      {
        mode = "n";
        key = "<leader>to";
        action = "<cmd>tabnew<CR>";
        options = {
          desc = "Open new tab";
        };
      }
      {
        mode = "n";
        key = "<leader>tx";
        action = "<cmd>tabclose<CR>";
        options = {
          desc = "Close current tab";
        };
      }
      {
        mode = "n";
        key = "<leader>tn";
        action = "<cmd>tabn<CR>";
        options = {
          desc = "Go to next tab";
        };
      }
      {
        mode = "n";
        key = "<leader>tp";
        action = "<cmd>tabp<CR>";
        options = {
          desc = "Go to previous tab";
        };
      }
    ];

    # Extra plugins (not available as built-in options)
    extraPlugins = with pkgs.vimPlugins; [
      tokyonight-nvim
    ];

    # Plugins
    plugins = {
      # File explorer
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          window = {
            width = 30;
          };
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

    # Additional Neovim configuration
    extraConfigLua = ''
      -- Additional Lua configuration can go here
      vim.opt.fillchars = { eob = " " }

      -- Configure tokyonight colorscheme
      require("tokyonight").setup({
        style = "night",
        transparent = false,
      })

      -- Set colorscheme
      vim.cmd.colorscheme("tokyonight")
    '';
  };
}
