{
  pkgs,
  lib,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  sshAddKeys = pkgs.writeShellScript "ssh-add-keys" ''
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
      ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || true
    fi
    if [ -f "$HOME/.ssh/id_rsa" ]; then
      ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/id_rsa" 2>/dev/null || true
    fi
  '';
  viewFileCmd = pkgs.writeShellScriptBin "v" ''
    if [ "$#" -eq 0 ]; then
      echo "Usage: v <file>" >&2
      exit 1
    fi

    file="$1"

    case "$file" in
      *.md)
        exec mdterm --follow "$file"
        ;;
      *)
        exec view \
          -c 'filetype plugin indent on' \
          -c 'syntax enable' \
          -c 'set autoread' \
          -c 'set updatetime=1000' \
          -c 'augroup v_autoreload' \
          -c 'autocmd!' \
          -c 'autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * checktime' \
          -c 'augroup END' \
          "$file"
        ;;
    esac
  '';
in
{
  # Shell configuration
  home.packages =
    with pkgs;
    [
      dua
      nixfmt-rfc-style
      nixfmt-tree
      google-cloud-sdk

      # Shell support tools
      gopass
      fd
      fzf

      wget
      tree
      ripgrep
      age
      starship
      viewFileCmd

      yazi
      dysk
      btop
      eza

      # Network diagnostic tools
      bind # dig, nslookup, host, and other DNS tools
      nmap # port scanning
      whois
      curl
      netcat
      socat
    ]
    ++ lib.optionals isLinux [
      # Linux-only packages
      inetutils # telnet, ftp, etc. - fails to build on macOS
      x11_ssh_askpass # SSH askpass for GUI password prompts
      traceroute
      mtr # advanced traceroute
      tcpdump # packet capture
    ];

  home.file.".cache/zsh/.keep".text = "";

  programs = {
    # Shell and utilities
    zsh = {
      enable = true;
      enableCompletion = true;
      completionInit = ''
        autoload -Uz compinit
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

        zcompdump="''${ZDOTDIR:-$HOME}/.zcompdump"
        if [[ -n "''${zcompdump}"(#qNmh-24) ]]; then
          compinit -C -i -d "''${zcompdump}"
        else
          compinit -i -d "''${zcompdump}"
        fi
        unset zcompdump
      '';

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
        "tm" = "tmux new -A -s main";

        "gt" = "git-town";
        "gts" = "git-town switch";
        "gtc" = "git-town continue";
        "gty" = "git-town sync";

        "zed" = "zeditor";
        "t" = "~/go/bin/task";

        "nixvi" = "nvim ~/mycfg";

      };

      initContent = lib.mkMerge [
        (lib.mkBefore ''
          # gcloud zsh completions must be on fpath before compinit.
          fpath=(${pkgs.google-cloud-sdk}/share/zsh/site-functions $fpath)
        '')

        # Initialize shell environment after completion setup
        ''
          # Source Nix daemon profile for proper PATH setup
          if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fi

          # Add custom paths (standard Nix paths are handled automatically)
          export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.npm-packages/bin:$HOME/.cargo/bin:$PATH"

          if [[ -o interactive && -t 0 && -t 1 && $options[zle] = on ]]; then
            __load_fzf_zsh() {
              unfunction __load_fzf_zsh 2>/dev/null || true
              bindkey '^I' expand-or-complete
              source <(${pkgs.fzf}/bin/fzf --zsh)
            }

            __fzf_lazy_widget() {
              local widget="$1"
              shift
              __load_fzf_zsh
              if (( ''${+widgets[$widget]} )); then
                zle "$widget" "$@"
              else
                zle redisplay
              fi
            }

            __fzf_lazy_file_widget() { __fzf_lazy_widget fzf-file-widget "$@"; }
            __fzf_lazy_cd_widget() { __fzf_lazy_widget fzf-cd-widget "$@"; }
            __fzf_lazy_history_widget() { __fzf_lazy_widget fzf-history-widget "$@"; }
            __fzf_lazy_completion_widget() { __fzf_lazy_widget fzf-completion "$@"; }

            zle -N __fzf_lazy_file_widget
            zle -N __fzf_lazy_cd_widget
            zle -N __fzf_lazy_history_widget
            zle -N __fzf_lazy_completion_widget
            bindkey -M emacs '^T' __fzf_lazy_file_widget
            bindkey -M viins '^T' __fzf_lazy_file_widget
            bindkey -M vicmd '^T' __fzf_lazy_file_widget
            bindkey -M emacs '\ec' __fzf_lazy_cd_widget
            bindkey -M viins '\ec' __fzf_lazy_cd_widget
            bindkey -M vicmd '\ec' __fzf_lazy_cd_widget
            bindkey -M emacs '^R' __fzf_lazy_history_widget
            bindkey -M viins '^R' __fzf_lazy_history_widget
            bindkey -M vicmd '^R' __fzf_lazy_history_widget
            bindkey '^I' __fzf_lazy_completion_widget
          fi

          # View function: use mdterm for markdown, view for everything else
          v() {
            command v "$@"
          }

          nixsw() {
            ${
              if isDarwin then
                ''sudo darwin-rebuild switch --flake "$HOME/mycfg#DR94XJ1435-Todor-Peychev-Todorov"''
              else
                ''sudo nixos-rebuild switch --flake "path:$HOME/mycfg#$(hostname)"''
            }
          }

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
        ''
      ];
    };

    # CLI tools
    ripgrep.enable = true;
    htop.enable = true;
    zoxide.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = false;
    };
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
      enable = true;
      enableDefaultConfig = false;
      extraOptionOverrides = {
        IgnoreUnknown = "UseKeychain";
      };
      extraConfig = ''
        MACs hmac-sha2-256,hmac-sha1,hmac-sha2-512,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
      '';
      includes = [
        "~/.orbstack/ssh/config"
      ];
      matchBlocks = {
        "blackbox.local" = {
          extraOptions = {
            MACs = "hmac-sha2-512-etm@openssh.com";
          };
        };
        "github.com" = {
          addKeysToAgent = "yes";
          identityFile = "~/.ssh/id_ed25519";
          extraOptions = {
            UseKeychain = "yes";
          };
        };
        "*" = {
          addKeysToAgent = "yes";
          identityFile = "~/.ssh/id_ed25519";
          extraOptions = lib.optionalAttrs isDarwin {
            UseKeychain = "yes";
          };
        };
      };
    };
  };

  # SSH services (Linux only - macOS uses system ssh-agent)
  services = lib.mkIf isLinux {
    ssh-agent = {
      enable = true;
    };
  };

  # Add SSH key to agent on login (Linux only)
  systemd.user.services = lib.mkIf isLinux {
    ssh-add-key = {
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
        ExecStart = "${sshAddKeys}";
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # Session variables for SSH agent (Linux only)
  # Use systemd.user.sessionVariables to ensure SSH_AUTH_SOCK is available
  # to all user processes, including GUI applications like lazygit
  systemd.user.sessionVariables = lib.mkIf isLinux {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };

  home.sessionVariables = {
    # Non-sensitive environment variables for todor
    BROWSER = "brave";
    TERMINAL = "kitty";

    # User-specific preferences
    EDITOR = "nvim";
    PAGER = "less";
  }
  // (
    if isLinux then
      {
        # Linux-only session variables
        # Pinentry for gopass/age password prompts
        PINENTRY_PROGRAM = "${pkgs.pinentry-bemenu}/bin/pinentry-bemenu";

        # SSH askpass for GUI password prompts
        SSH_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
        SSH_ASKPASS_REQUIRE = "prefer";
      }
    else
      { }
  );
}
