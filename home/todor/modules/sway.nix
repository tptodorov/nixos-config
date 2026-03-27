{
  config,
  lib,
  pkgs,
  laptop ? false,
  ...
}:
{
  # Sway window manager configuration
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    checkConfig = false; # Disable config validation
    config = rec {
      modifier = "Mod4"; # Super key
      terminal = "kitty";
      menu = "dms ipc call spotlight toggle";

      # Keyboard layout - matching Niri config
      input = {
        "*" = {
          xkb_layout = "us,bg";
          xkb_variant = "basic,phonetic";
          xkb_options = "grp:rwin_toggle";
          repeat_delay = "250";
          repeat_rate = "50";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "disabled";
          dwt = "enabled";
          accel_profile = "adaptive";
        };
      };

      # Key bindings
      keybindings = {
        # Terminal
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+t" = "exec ${terminal}";

        # Application launcher
        "${modifier}+space" = "exec ${menu}";

        # DMS Keybindings
        "${modifier}+slash" = "exec dms ipc call spotlight toggle";
        "${modifier}+v" = "exec dms ipc call clipboard toggle";
        "${modifier}+m" = "exec dms ipc call processlist focusOrToggle";
        "${modifier}+comma" = "exec dms ipc call settings focusOrToggle";
        "${modifier}+Shift+slash" = "exec dms ipc call keybinds toggle sway";

        # File manager
        "${modifier}+n" = "exec nautilus";

        # Browser
        "${modifier}+s" = "exec brave";

        # Window management - focus
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        # Window management - move
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        # Window management - layouts
        "${modifier}+backslash" = "splitv";
        "${modifier}+b" = "splith";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+a" = "focus parent";

        # Floating/tiling focus
        "${modifier}+Alt+f" = "focus mode_toggle";
        "${modifier}+Alt+Shift+f" = "focus mode_toggle";

        # Close window
        "${modifier}+q" = "kill";

        # Workspaces
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        # Move to workspaces
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";

        # Workspace navigation
        "${modifier}+Page_Down" = "workspace next";
        "${modifier}+Page_Up" = "workspace prev";
        "${modifier}+Tab" = "workspace back_and_forth";

        # Screenshots
        "Print" =
          "exec grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') ~/Screenshots/screenshot-$(date +%s).png";
        "${modifier}+Shift+s" = "exec grim ~/Screenshots/screenshot-$(date +%s).png";
        "Alt+Print" = "exec sh -c 'grim -g \"$(slurp)\" ~/Screenshots/screenshot-$(date +%s).png'";

        # Power management
        "${modifier}+Shift+p" = "exec ${pkgs.systemd}/bin/systemctl suspend";

        # Audio controls
        "XF86AudioRaiseVolume" = "exec dms ipc call audio increment 3";
        "XF86AudioLowerVolume" = "exec dms ipc call audio decrement 3";
        "XF86AudioMute" = "exec dms ipc call audio mute";

        # Brightness controls
        "XF86MonBrightnessUp" = "exec dms ipc call brightness increment 5";
        "XF86MonBrightnessDown" = "exec dms ipc call brightness decrement 5";

        # Exit/reload
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Ctrl+Shift+r" = "reload";
      };

      # Bar configuration
      bars = [
      ];

      # Startup commands - matching Niri applications
      startup = [
        { command = "dms run"; }
        { command = "mako"; }
        # Idle management handled by DMS (Settings app: Mod+comma → Power & Sleep / Lock Screen)
        { command = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :1"; }
        { command = "sh -c '$HOME/.config/sway/scripts/ssh-agent-init.sh'"; }
        {
          command = "sh -c '${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store'";
        }
        {
          command = "sh -c '${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store'";
        }
        {
          command = "${pkgs.kitty}/bin/kitty";
          always = false;
        }
        {
          command = "${pkgs.brave}/bin/brave";
          always = false;
        }
        {
          command = "${pkgs.spotify}/bin/spotify";
          always = false;
        }
      ];

      # Window decorations
      window = {
        border = 2;
        titlebar = false;
      };

      # Gaps
      gaps = {
        inner = 5;
        outer = 5;
      };

      # Colors - Material Design Dark theme (matching DMS)
      colors = {
        focused = {
          border = "#1db8f8";
          background = "#121212";
          text = "#ffffff";
          indicator = "#1db8f8";
          childBorder = "#1db8f8";
        };
        focusedInactive = {
          border = "#424242";
          background = "#1e1e1e";
          text = "#bdbdbd";
          indicator = "#616161";
          childBorder = "#424242";
        };
        unfocused = {
          border = "#212121";
          background = "#121212";
          text = "#757575";
          indicator = "#303030";
          childBorder = "#212121";
        };
        urgent = {
          border = "#ff5252";
          background = "#ff5252";
          text = "#ffffff";
          indicator = "#ff5252";
          childBorder = "#ff5252";
        };
        placeholder = {
          border = "#212121";
          background = "#121212";
          text = "#757575";
          indicator = "#303030";
          childBorder = "#212121";
        };
        background = "#121212";
      };

      output = {
        "*" = {
          bg = "#000000 solid_color";
        };
      };
    };

    extraConfig = ''
      # 3-finger swipe gestures for workspace switching
      bindgesture swipe:right workspace prev
      bindgesture swipe:left workspace next

      # 3-finger swipe up/down
      bindgesture swipe:up exec dms ipc call spotlight toggle
      bindgesture swipe:down exec makoctl dismiss --all

      # 4-finger gestures
      bindgesture swipe:4:left workspace next
      bindgesture swipe:4:right workspace prev
      bindgesture swipe:4:up fullscreen toggle
      bindgesture swipe:4:down floating toggle
    '';
  };

  # Sway-specific configuration files and scripts
  home.file = {
    # Electron flags for proper HiDPI scaling on Wayland
    ".config/electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform,WaylandWindowDecorations
      --ozone-platform=wayland
      ${lib.optionalString laptop "--force-device-scale-factor=2.0"}
    '';

    # SSH agent initialization script
    ".config/sway/scripts/ssh-agent-init.sh" = {
      text = ''
        #!/bin/sh
        # Ensure SSH_AUTH_SOCK points to Home Manager's ssh-agent
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd SSH_AUTH_SOCK

        # Add SSH keys to ssh-agent
        if [ -f "$HOME/.ssh/id_rsa" ]; then
          ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/id_rsa" 2>/dev/null
        fi
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
          ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
        fi
        if [ -f "$HOME/.ssh/id_ecdsa" ]; then
          ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/id_ecdsa" 2>/dev/null
        fi

        echo "SSH agent: SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
      '';
      executable = true;
    };
  };

  # Sway-specific environment variables are set inside sway config itself.
  # Global session variables (XDG_CURRENT_DESKTOP, QT_QPA_PLATFORM, etc.)
  # are NOT set here to avoid conflicts with GNOME or other desktop sessions.

  # Sway-specific packages
  home.packages = with pkgs; [
    sway
    swaybg
    swayidle
    swaylock
    wl-clipboard
    cliphist
    grim
    slurp
    xwayland-satellite
    kitty
    spotify
    openssh
    dbus
  ];
}
