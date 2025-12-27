return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Existing servers
        css_variables = {
          filetypes = { "css", "scss", "less", "svelte" },
        },
        roc_ls = {},
        biome = {},

        -- Nix
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixfmt" },
              },
            },
          },
        },
        nixd = {},

        -- Zig
        zls = {},

        -- Go
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },

        -- Rust
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },

        -- PHP
        phpactor = {},

        -- TypeScript/JavaScript
        ts_ls = {},

        -- Lua (for Neovim config)
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
      },
    },
  },
}
