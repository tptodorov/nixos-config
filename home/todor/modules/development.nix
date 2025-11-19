{
  pkgs,
  lib,
  vm ? false,
  standalone ? false,
  ...
}:
{
  # Development tools and environment
  home.packages = with pkgs; [
    devenv
    git-town
    nil
    gopass
    zed-editor
    nixd
    warp-terminal
    amp-cli
    crush  # AI coding agent for terminal

    # Zig development
    zig
    zls

    # Go development
    go
    gopls
    gotools

    # Rust development
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # PHP development
    php
    phpactor

    # Build tools
    gnumake
  ] ++ lib.optionals standalone [
    # Install without Home Manager managing configs in standalone mode
    git
    gh
    lazygit
  ];

  programs = {
    # Version control
    git = {
      enable = !standalone;  # Disable in standalone mode to avoid managing config
      settings = {
        user = {
          name = "Todor Todorov";
          email = "98095+tptodorov@users.noreply.github.com";
        };
      };
    };

    gh = {
      enable = !standalone;  # Disable in standalone mode to avoid managing config
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
      enable = !standalone;  # Disable in standalone mode to avoid managing config
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
    # Zed Editor settings file
    ".config/zed/settings.json".source = ../config/zed/private_settings.json;
  } // lib.optionalAttrs standalone {
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
  };
}
