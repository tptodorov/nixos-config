{
  pkgs,
  lib,
  ...
}:
let
  # Custom cline wrapper that installs and runs cline via npm
  cline = pkgs.writeShellScriptBin "cline" ''
    # Ensure cline is installed globally
    if ! command -v ${pkgs.nodejs}/bin/npm list -g cline &> /dev/null; then
      echo "Installing cline globally..."
      ${pkgs.nodejs}/bin/npm install -g cline
    fi

    # Run cline with all arguments
    exec ${pkgs.nodejs}/bin/npx cline "$@"
  '';

  # Custom kilocode wrapper that installs and runs kilocode via npm
  kilocode = pkgs.writeShellScriptBin "kilocode" ''
    NPM_PREFIX="$HOME/.npm-packages"
    export PATH="$NPM_PREFIX/bin:$PATH"

    # Ensure kilocode is installed globally
    if ! ${pkgs.nodejs}/bin/npm list -g --prefix="$NPM_PREFIX" @kilocode/cli &> /dev/null; then
      echo "Installing @kilocode/cli globally..."
      ${pkgs.nodejs}/bin/npm install -g --prefix="$NPM_PREFIX" @kilocode/cli
    fi

    # Run kilocode with all arguments
    exec "$NPM_PREFIX/bin/kilocode" "$@"
  '';

  # Custom claude wrapper that runs claude-code via npx
  claude = pkgs.writeShellScriptBin "claude" ''
    # Run claude-code with all arguments
    exec ${pkgs.nodejs}/bin/npx claude-code "$@"
  '';
in
{
  # Development tools and environment
  home.packages = with pkgs; [
    # shell productivity (cross-platform)
    devenv
    nil
    gopass
    pinentry-bemenu # Wayland-native pinentry for gopass/age
    nixd
    statix # Nix linter and code suggestions
    zed-editor
    warp-terminal
    amp-cli
    crush # AI coding agent for terminal
    jq # for jsontools plugin
    neovim # for LazyVim setup
    jiratui

    # Neovim/LazyVim dependencies (cross-platform)
    tree-sitter # Tree-sitter CLI
    ripgrep # Fast grep for telescope
    fd # Fast find for telescope
    fzf # Fuzzy finder
    unzip # For Mason package extraction
    python3 # For Mason and some LSP servers
    wget # For downloading packages
    curl # For downloading packages

    # Zig development (cross-platform)
    zig
    zls

    # Go development (cross-platform)
    go
    gopls
    gotools

    # ops (cross-platform)
    flyctl # Fly.io CLI
    awscli2 # for aws plugin
    kubectl # for kubectl plugin
    bun # for bun plugin
    nodejs # for npm plugin
    nodePackages.typescript-language-server # TypeScript LSP

    # AI coding agent (cross-platform)
    cline
    kilocode

    # Rust development (cross-platform)
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # PHP development (cross-platform)
    php
    phpactor

    # Lua development (for Neovim config, cross-platform)
    lua-language-server

    # Build tools (cross-platform)
    gnumake
    git
    gh
    lazygit
    git-town
    pre-commit
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    # Linux-only packages
    pinentry-gnome3 # GUI pinentry for gopass/age (Linux only)
    gcc # C compiler for treesitter (macOS has clang by default)
    zenity # Askpass helper for sudo (used by Claude Code)
    bluetuith # TUI Bluetooth manager (Linux only)
  ];

  programs = {
    # Version control
    git = {
      enable = true;
      settings = {
        user = {
          name = "Todor Todorov";
          email = "98095+tptodorov@users.noreply.github.com";
        };
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      hosts = {
        "github.com" = {
          user = "tptodorov";
        };
      };
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            lightTheme = true;
            activeBorderColor = [
              "blue"
              "bold"
            ];
            inactiveBorderColor = [ "black" ];
            selectedLineBgColor = [ "default" ];
          };
          showRandomTip = false;
        };
        git = {
          # Disable auto-fetch on startup and periodically - it blocks keyboard input
          autoFetch = false;
          # Keep auto-refresh enabled but increase interval to reduce startup blocking
          autoRefresh = true;
          fetchAll = false;
        };
      };
    };

    # Development environment
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

  };

  # File configurations
  home.file = {
    # Neovim LazyVim configuration
    ".config/nvim".source = ../config/nvim;

    # Zed Editor settings file
    ".config/zed/settings.json".source = ../config/zed/private_settings.json;
    # Git identity for standalone mode (managed by Home Manager)
    ".config/git/config.d/identity".text = ''
      [user]
        name = Todor Todorov
        email = 98095+tptodorov@users.noreply.github.com
    '';
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";

    # Askpass configuration for sudo (used by Claude Code)
    SUDO_ASKPASS = "${pkgs.writeShellScript "askpass" ''
      ${pkgs.zenity}/bin/zenity --password --title="sudo password prompt"
    ''}";
  };

  services = {
    # Container services
    podman.enable = !pkgs.stdenv.isDarwin;
  };
}
