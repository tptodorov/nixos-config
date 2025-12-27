-- Language support plugins
-- Note: LazyVim extras imports moved to 00-extras.lua to load first
return {
  -- Additional formatters and linters
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        zig = { "zigfmt" },
        php = { "php_cs_fixer" },
      },
    },
  },

  -- Treesitter configuration for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "nix",
        "rust",
        "toml",
        "typescript",
        "javascript",
        "tsx",
        "json",
        "lua",
        "vim",
        "yaml",
        "markdown",
        "markdown_inline",
        "php",
        "zig",
      },
    },
  },

  -- Mason (LSP installer) - minimal config for NixOS
  -- We rely on system-provided LSP servers from Nix packages
  {
    "mason-org/mason.nvim",
    opts = {
      -- Don't auto-install packages on NixOS - we use Nix packages instead
      ensure_installed = {},
    },
  },
}
