{
  pkgs,
  lib,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # Development tools and environment
  home.packages =
    with pkgs;
    [
      # shell productivity (cross-platform)
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

      # Neovim/LazyVim dependencies (cross-platform)
      tree-sitter # Tree-sitter CLI
      ripgrep # Fast grep for telescope
      fd # Fast find for telescope
      fzf # Fuzzy finder
      unzip # For Mason package extraction
      (python3.withPackages (
        ps: with ps; [
          pip
        ]
      )) # Python with pip
      uv # Fast Python package installer and resolver
      wget # For downloading packages
      curl # For downloading packages

      # Zig development (cross-platform)
      zig
      zls

      # Go development (cross-platform)
      go
      gopls
      gotools
      jetbrains.goland

      # ops (cross-platform)
      flyctl # Fly.io CLI
      awscli2 # for aws plugin
      kubectl # for kubectl plugin
      bun # for bun plugin
      nodejs # for npm plugin
      nodePackages.typescript-language-server # TypeScript LSP

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
      # Docker and container tools (cross-platform)
      docker
      docker-compose
      lazydocker # TUI Docker client
    ]
    ++ lib.optionals isLinux [
      # Linux-only packages
      pinentry-bemenu # Wayland-native pinentry for gopass/age
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
          branchPrefix = "todor/";
          # Disable auto-fetch on startup and periodically - it blocks keyboard input
          autoFetch = false;
          # Keep auto-refresh enabled but increase interval to reduce startup blocking
          autoRefresh = true;
          fetchAll = false;
        };
        customCommands = [
          {
            key = "Y";
            context = "global";
            description = "Git Town sYnc";
            command = "git town sync --all";
            loadingText = "Syncing";
            output = "log";
          }
          {
            key = "U";
            context = "global";
            description = "Git Town Undo (undo the last Git Town command)";
            command = "git-town undo";
            prompts = [
              {
                type = "confirm";
                title = "Undo Last Command";
                body = "Are you sure you want to Undo the last Git Town command?";
              }
            ];
            loadingText = "Undoing Git Town Command";
            output = "log";
          }
          {
            key = "!";
            context = "global";
            description = "Git Town Repo (opens the repo link)";
            command = "git-town repo";
            loadingText = "Opening Repo Link";
            output = "log";
          }
          {
            key = "a";
            context = "localBranches";
            description = "Git Town Append";
            prompts = [
              {
                type = "input";
                title = "Enter name of new child branch. Branches off of '{{.CheckedOutBranch.Name}}'";
                key = "BranchName";
                initialValue = "todor/";
              }
            ];
            command = "git-town append {{.Form.BranchName}}";
            loadingText = "Appending";
            output = "log";
          }
          {
            key = "H";
            context = "localBranches";
            description = "Git Town Hack (creates a new branch)";
            prompts = [
              {
                type = "input";
                title = "Enter name of new branch. Branches off of 'Main'";
                key = "BranchName";
                initialValue = "todor/";
              }
            ];
            command = "git-town hack {{.Form.BranchName}}";
            loadingText = "Hacking";
            output = "log";
          }
          {
            key = "I";
            context = "localBranches";
            description = "Git Town Initiate hack+propose";
            prompts = [
              {
                type = "input";
                title = "Enter name of new branch. Branches off of 'Main'";
                key = "BranchName";
                initialValue = "todor/";
              }
              {
                type = "input";
                title = "Enter Commit Message";
                key = "CommitMessage";
              }
            ];
            command = "git-town hack {{.Form.BranchName}} -m '{{.Form.CommitMessage}}' -c --propose";
            loadingText = "Hacking";
            output = "log";
          }
          {
            key = "D";
            context = "localBranches";
            description = "Git Town Delete (deletes the current feature branch and sYnc)";
            command = "git-town delete";
            prompts = [
              {
                type = "confirm";
                title = "Delete current feature branch";
                body = "Are you sure you want to delete the current feature branch?";
              }
            ];
            loadingText = "Deleting Feature Branch";
            output = "log";
          }
          {
            key = "g";
            context = "localBranches";
            description = "Git Town Propose (creates a pull request)";
            command = "git-town propose";
            loadingText = "Creating pull request";
            output = "log";
          }
          {
            key = "b";
            context = "localBranches";
            description = "Git Town Prepend (creates a branch before/between current and parent)";
            prompts = [
              {
                type = "input";
                title = "Enter name of the for child branch between '{{.CheckedOutBranch.Name}}' and its parent";
                key = "BranchName";
              }
            ];
            command = "git-town prepend {{.Form.BranchName}}";
            loadingText = "Prepending";
            output = "log";
          }
          {
            key = "S";
            context = "localBranches";
            description = "Git Town Skip (skip branch with merge conflicts when syncing)";
            command = "git-town skip";
            loadingText = "Skiping";
            output = "log";
          }
          {
            key = "G";
            context = "files";
            description = "Git Town GO Continue (continue after resolving merge conflicts)";
            command = "git-town continue";
            loadingText = "Continuing";
            output = "log";
          }
          {
            key = "E";
            context = "localBranches";
            description = "Git Town Compress";
            command = "git-town compress";
            loadingText = "Compressing";
            output = "log";
          }
        ];
      };
    };

    # Development environment
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
      # stdlib = ''
      #   # Add devenv integration for use_devenv in .envrc files
      #   use_devenv() {
      #     watch_file devenv.nix
      #     watch_file devenv.yaml
      #     watch_file devenv.lock
      #     eval "$(devenv print-dev-env)"
      #   }
      # '';
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
  }
  // (
    if isLinux then
      {
        # Askpass configuration for sudo (used by Claude Code) - Linux only
        SUDO_ASKPASS = "${pkgs.writeShellScript "askpass" ''
          ${pkgs.zenity}/bin/zenity --password --title="sudo password prompt"
        ''}";
      }
    else
      { }
  );

  services = {
    # Container services
    podman.enable = isLinux;
  };
}
