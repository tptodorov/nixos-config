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
    checkConfig = false;  # Disable config validation
    config = rec {
      modifier = "Mod4"; # Super key
      terminal = "ghostty";
      menu = "wofi --show drun";

      # Keyboard layout
      input = {
        "*" = {
          xkb_layout = "us,bg";
          xkb_variant = "basic,phonetic";
          xkb_options = "grp:rwin_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };



      # Key bindings
      keybindings = {
        # Terminal
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+t" = "exec ${terminal}";

        # Application launcher
        "${modifier}+space" = "exec ${menu}";

        # File manager
        "${modifier}+n" = "exec nautilus";

        # Browser
        "${modifier}+s" = "exec brave";

        # Window management
        "${modifier}+q" = "kill";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+v" = "splitv";
        "${modifier}+b" = "splith";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+a" = "focus parent";

        # Workspaces
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";

        # Screenshots
        "Print" = "exec grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') /tmp/screenshot-$(date +%s).png";
        "${modifier}+Shift+s" = "exec grim /tmp/screenshot-$(date +%s).png";

        # Exit/reload
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+Shift+c" = "reload";
      };

      # Bar configuration
      bars = [
        {
          statusCommand = "while :; do echo ''; sleep 1; done";
          command = "waybar";
        }
      ];

      # Startup commands
      startup = [
        { command = "waybar"; }
        { command = "mako"; }
        { command = "dms run"; }
      ];

      # Gaps
      gaps = {
        inner = 10;
        outer = 5;
      };

      # Colors
      colors = {
        focused = {
          border = "#4c7899";
          background = "#285577";
          text = "#ffffff";
          indicator = "#2e9ef4";
          childBorder = "#285577";
        };
        focusedInactive = {
          border = "#333333";
          background = "#5f676e";
          text = "#ffffff";
          indicator = "#484e50";
          childBorder = "#5f676e";
        };
        unfocused = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
          indicator = "#292d2e";
          childBorder = "#222222";
        };
        urgent = {
          border = "#2f343a";
          background = "#900000";
          text = "#ffffff";
          indicator = "#900000";
          childBorder = "#900000";
        };
      };

      output = {
        "*" = {
          bg = "#000000 solid_color";
        };
      };
    };
  };

  # Sway-specific packages
  home.packages = with pkgs; [
    sway
    swaybg
    swayidle
    swaylock
    wl-clipboard
    grim
    slurp
  ];
}
