{
  pkgs,
  lib,
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
    fzf

    # SSH askpass for GUI password prompts
    x11_ssh_askpass

    wget
    tree
    ripgrep
    age
    sops
    starship

    yazi
    dysk

    # Network diagnostic tools
    bind # dig, nslookup, host, and other DNS tools
    inetutils # telnet, ftp, etc.
    traceroute
    mtr # advanced traceroute
    nmap # port scanning
    tcpdump # packet capture
    whois
    curl
    netcat
    socat
  ];

  programs = {
    # Shell and utilities
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "history"
          "pass"
          "jsontools"
          "colorize"
        ];
        # Removed plugins for faster startup:
        # - z: replaced by zoxide (already enabled, faster)
        # - brew: only useful on macOS with Homebrew
        # - docker: heavy completion loading - use lazy-load instead
        # - aws: heavy completion loading - use lazy-load instead
        # - kubectl: heavy completion loading - use lazy-load instead
        # - bun: minimal benefit
        # - tmux: minimal benefit, aliases can be added manually
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
        "t" = "~/go/bin/task";

        "nixvi" = "nvim ~/mycfg";
        "nixsw" = "sudo nixos-rebuild switch --flake ~/mycfg";

      };

      # Initialize shell environment (runs before Oh My Zsh)
      initExtraFirst = ''
        # Skip compaudit permission checks - significant performance gain
        ZSH_DISABLE_COMPFIX=true
      '';

      # Initialize shell environment (runs after Oh My Zsh)
      initContent = ''
        # Source Nix daemon profile for proper PATH setup
        if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi

        # Direnv integration
        eval "$(direnv hook zsh)"

        # Add custom paths (standard Nix paths are handled automatically)
        export PATH="$HOME/go/bin:$HOME/.npm-packages/bin:$PATH"

        # Source Home Manager session variables
        if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi

        # Lazy-load heavy completions (only loaded when first used)
        if command -v kubectl &>/dev/null; then
          kubectl() {
            unfunction kubectl
            source <(command kubectl completion zsh)
            kubectl "$@"
          }
        fi

        if command -v docker &>/dev/null; then
          docker() {
            unfunction docker
            source <(command docker completion zsh 2>/dev/null)
            docker "$@"
          }
        fi

        if command -v aws &>/dev/null; then
          aws() {
            unfunction aws
            complete -C aws_completer aws
            aws "$@"
          }
        fi
      '';
    };

    # CLI tools
    ripgrep.enable = true;
    htop.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    eza.enable = false;
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

    # Tmux terminal multiplexer
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;

      # Vim-friendly prefix key (Ctrl-a instead of Ctrl-b)
      prefix = "C-a";

      # Additional tmux configuration
      extraConfig = ''
        # Vim-style pane switching
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Vim-style pane resizing
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # Reload config file
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # Enable mouse mode
        set -g mouse on

        # Start windows and panes at 1, not 0
        set -g base-index 1
        setw -g pane-base-index 1

        # Renumber windows when a window is closed
        set -g renumber-windows on

        # Increase scrollback buffer size
        set -g history-limit 10000

        # Enable vi mode for copy mode
        setw -g mode-keys vi

        # Vim-style copy mode bindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

        # Paste with prefix + p
        bind p paste-buffer

        # Don't exit copy mode when dragging with mouse
        unbind -T copy-mode-vi MouseDragEnd1Pane

        # Status bar styling
        set -g status-bg colour235
        set -g status-fg colour136
        set -g status-left-length 20
        set -g status-left '#[fg=colour166]#S #[fg=colour245]| '
        set -g status-right '#[fg=colour245]%d %b %R'

        # Window status styling
        setw -g window-status-current-style 'fg=colour81 bg=colour238 bold'
        setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
        setw -g window-status-style 'fg=colour138 bg=colour235 none'
        setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

        # Pane border styling
        set -g pane-border-style 'fg=colour238'
        set -g pane-active-border-style 'fg=colour81'

        # Message styling
        set -g message-style 'fg=colour232 bg=colour166 bold'

        # Reduce escape time for better vim experience
        set -sg escape-time 0

        # Enable focus events for vim
        set -g focus-events on

        # Enable true color support
        set -g default-terminal "screen-256color"
        set -ga terminal-overrides ",*256col*:Tc"
      '';
    };

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

  # Add SSH key to agent on login
  systemd.user.services.ssh-add-key = {
    Unit = {
      Description = "Add SSH key to agent";
      After = [
        "ssh-agent.service"
        "graphical-session.target"
      ];
      Requires = [ "ssh-agent.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [
        "SSH_AUTH_SOCK=%t/ssh-agent"
        "SSH_ASKPASS=${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
        "SSH_ASKPASS_REQUIRE=prefer"
        "DISPLAY=:0"
      ];
      ExecStart = "${pkgs.openssh}/bin/ssh-add /home/todor/.ssh/id_rsa";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Session variables for SSH agent
  # Use systemd.user.sessionVariables to ensure SSH_AUTH_SOCK is available
  # to all user processes, including GUI applications like lazygit
  systemd.user.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };

  home.sessionVariables = {
    # Non-sensitive environment variables for todor
    BROWSER = "brave";
    TERMINAL = "ghostty";

    # User-specific preferences
    EDITOR = "nvim";
    PAGER = "less";

    # Pinentry for gopass/age password prompts
    PINENTRY_PROGRAM = "${pkgs.pinentry-bemenu}/bin/pinentry-bemenu";

    # SSH askpass for GUI password prompts
    SSH_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };
}
