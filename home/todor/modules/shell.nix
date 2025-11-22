{
  pkgs,
  ...
}:
{
  imports = [
    ../secrets/secrets.nix
  ];

  # Shell configuration
  home.packages = with pkgs; [
    dua
    nixfmt-rfc-style
    nixfmt-tree

    # Supporting packages for Oh My Zsh plugins
    gopass # for pass plugin
    fd

    wget
    tree
    ripgrep
    age
    sops
    starship
  ];

  programs = {
    # Shell and utilities
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "brew"
          "docker"
          "history"
          "pass"
          "z"
          "jsontools"
          "aws"
          "kubectl"
          "bun"
          "colorize"
          "common-aliases"
        ];
      };

      # History configuration
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        ignoreSpace = true;
      };

      # Custom shell aliases
      shellAliases = {
        # Directory navigation shortcuts
        "cd.." = "cd ..";
        ".." = "cd ..";
        "..." = "cd ../../../";
        "...." = "cd ../../../../";
        "....." = "cd ../../../../";
        ".4" = "cd ../../../../";
        ".5" = "cd ../../../../../";

        # Enhanced grep aliases (grep --color already set by common-aliases plugin)
        "egrep" = "egrep --color=auto";
        "fgrep" = "fgrep --color=auto";
        "hgrep" = "history|grep";

        # System utilities
        "bc" = "bc -l";
        "mkdir" = "mkdir -pv";
        "j" = "jobs -l";
        "now" = "date +\"%T\"";
        "nowtime" = "date +\"%T\"";
        "nowdate" = "date +\"%d-%m-%Y\"";

        # Editor aliases
        "vi" = "nvim";
        "svi" = "sudo nvim";
        "vis" = "nvim \"+set si\"";
        "edit" = "nvim";

        # Password manager
        "pass" = "gopass";

        # Network utilities
        "ping" = "ping -c 5";
        "fastping" = "ping -c 100 -s.2";
        "header" = "curl -I";
        "headerc" = "curl -I --compress";

        # System access
        "root" = "sudo -i";
        "su" = "sudo -i";

        # Download utilities
        "wget" = "wget -c";

        # Development tools
        "lg" = "lazygit";
        "b" = "bun";

        "gt" = "git-town";
        "gts" = "git-town switch";
        "gtc" = "git-town continue";
        "gty" = "git-town sync";

        "zed" = "zeditor";

      };

      # Initialize shell environment for standalone mode (Omarchy)
      initContent = ''
        # Source Nix daemon profile for proper PATH setup
        if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi

        # Ensure Home Manager profile is in PATH
        export PATH="$HOME/.nix-profile/bin:$PATH"
        export PATH="$HOME/.local/bin:$PATH"

        # Source Home Manager session variables
        if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
      '';
    };

    # CLI tools
    ripgrep.enable = true;
    htop.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    eza.enable = true;
    starship = {
      enable = true;
      settings = {
        # Inserts a blank line between shell prompts
        add_newline = true;
        command_timeout = 1000;

        # Move the directory to the second line
        format = "$all$directory$character";

        # Replace the "❯" symbol in the prompt with "➜"
        character = {
          success_symbol = "[➜](bold green)";
        };

        # Disable the package module, hiding it from the prompt completely
        package = {
          disabled = true;
        };

        directory = {
          truncation_length = 8;
          truncation_symbol = "…/";
        };
      };
    };
    fastfetch.enable = true;

    # SSH
    ssh = {
      enable = !pkgs.stdenv.isDarwin;
      enableDefaultConfig = false;
      extraConfig = ''
        MACs hmac-sha2-256,hmac-sha1,hmac-sha2-512,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
      '';
      includes = [
        "~/.orbstack/ssh/config"
      ];
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
          identityFile = "~/.ssh/id_rsa";
        };
      };
    };
  };

  # SSH services
  services = {
    ssh-agent = {
      enable = true;
    };
  };

  # Session variables for SSH agent
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";

    # Non-sensitive environment variables for todor
    BROWSER = "brave";
    TERMINAL = "ghostty";

    # User-specific preferences
    EDITOR = "nvim";
    PAGER = "less";
  };
}
