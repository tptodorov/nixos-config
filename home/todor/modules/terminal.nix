{
  pkgs,
  lib,
  vm ? false,
  ...
}:
{
  imports = [
    # Import user-specific environment configuration (non-sensitive)
    ../secrets/environment.nix
    # Import encrypted secrets management (conditionally disabled in VMs)
    ../secrets/secrets.nix
  ];

  # Terminal and shell configuration
  home.packages = with pkgs; [
    dua
    nixfmt-rfc-style
    nixfmt-tree

    # Supporting packages for Oh My Zsh plugins
    jq # for jsontools plugin
    pass # for pass plugin
    awscli2 # for aws plugin
    kubectl # for kubectl plugin
    nodejs # for npm plugin
    python3 # for python plugin
    bun # for bun plugin
  ];

  programs = {
    # Terminal emulators
    ghostty = {
      enable = !vm;  # Use ghostty on blackbox, not in VMs
      enableZshIntegration = !vm;
      settings = {
        theme = "TokyoNight Storm";
        font-size = 12;
        font-family = "ZedMono Nerd Font";
      };
    };

    rio.enable = !vm;  # Enable on blackbox, disable in VMs

    kitty = {
      enable = !vm;  # Enable on blackbox, disable in VMs
      settings = {
        linux_display_server = "wayland";
        wayland_titlebar_color = "system";
      };
    };

    # Enable alacritty on both VM and blackbox
    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = { x = 10; y = 10; };
          decorations = "full";
        };
        font = {
          normal = { family = "ZedMono Nerd Font"; };
          size = 12;
        };
        colors = {
          primary = {
            background = "#1a1b26";
            foreground = "#c0caf5";
          };
        };
      };
    };

    # Foot terminal - VM-specific
    foot = lib.mkIf vm {
      enable = true;
      settings = {
        main = {
          font = "ZedMono Nerd Font:size=12";
          dpi-aware = "yes";
        };
        colors = {
          background = "1a1b26";
          foreground = "c0caf5";
        };
      };
    };

    # Shell and utilities
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "brew"
          "docker"
          "npm"
          "python"
          "history"
          "pass"
          "z"
          "jsontools"
          "aws"
          "kubectl"
          "bun"
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
        "path" = "echo -e \${PATH//:/\\\\n}";
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

        # AWS/EC2 shortcuts
        "ssh2ec2" =
          "ssh -oStrictHostKeyChecking=no -i ~/.ec2/laptop-\${AWS_DEFAULT_REGION}.pem -l ec2-user";
        "scp2ec2" = "scp -i ~/.ec2/laptop.pem";

        # Development tools
        "lg" = "lazygit";
        "b" = "bun";
        "cs" = "coursier";
        "bb" = "ssh blackbox";
      };
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
      enable = true;
      enableDefaultConfig = false;
    };
  };

  # SSH services
  services = {
  };
}
