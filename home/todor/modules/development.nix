{
  pkgs,
  lib,
  vm ? false,
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

  # Zed Editor settings file
  home.file.".config/zed/settings.json".source = ../config/zed/private_settings.json;

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
