{
  pkgs,
  lib,
  ...
}:
{
  # Development tools and environment
  home.packages = with pkgs; [
    # shell productivity
    devenv
    nil
    gopass
    nixd
    zed-editor
    warp-terminal
    amp-cli
    crush  # AI coding agent for terminal
    jq # for jsontools plugin
    neovim

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
    awscli2 # for aws plugin
    kubectl # for kubectl plugin
    python3 # for python plugin
    bun # for bun plugin
    nodejs # for npm plugin

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
    git
    gh
    lazygit
    git-town
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
