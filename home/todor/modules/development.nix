{
  pkgs,
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
in
{
  # Development tools and environment
  home.packages = with pkgs; [
    # shell productivity
    devenv
    nil
    gopass
    nixd
    statix # Nix linter and code suggestions
    zed-editor
    warp-terminal
    amp-cli
    crush # AI coding agent for terminal
    jq # for jsontools plugin
    neovim # for LazyVim setup
    jiratui
    bluetuith # TUI Bluetooth manager

    # Neovim/LazyVim dependencies
    gcc # C compiler for treesitter
    tree-sitter # Tree-sitter CLI
    ripgrep # Fast grep for telescope
    fd # Fast find for telescope
    fzf # Fuzzy finder
    unzip # For Mason package extraction
    python3 # For Mason and some LSP servers
    wget # For downloading packages
    curl # For downloading packages

    # Askpass helper for sudo (used by Claude Code)
    zenity

    # Zig development
    zig
    zls

    # Go development
    go
    gopls
    gotools

    # ops
    flyctl # Fly.io CLI
    awscli2 # for aws plugin
    kubectl # for kubectl plugin
    bun # for bun plugin
    nodejs # for npm plugin
    nodePackages.typescript-language-server # TypeScript LSP
    cline # AI coding agent

    # Rust development
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # PHP development
    php
    phpactor

    # Lua development (for Neovim config)
    lua-language-server

    # Build tools
    gnumake
    git
    gh
    lazygit
    git-town
    pre-commit
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
        gui.theme = {
          lightTheme = true;
          activeBorderColor = [
            "blue"
            "bold"
          ];
          inactiveBorderColor = [ "black" ];
          selectedLineBgColor = [ "default" ];
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

    claude-code.enable = true;
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
