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

      # Keyboard layout - matching Niri config
      input = {
        "*" = {
          xkb_layout = "us,bg";
          xkb_variant = "basic,phonetic";
          xkb_options = "grp:rwin_toggle";
          repeat_delay = "300";
          repeat_rate = "50";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
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
        "${modifier}+v" = "splitv";
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
        "Print" = "exec grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') ~/Screenshots/screenshot-$(date +%s).png";
        "${modifier}+Shift+s" = "exec grim ~/Screenshots/screenshot-$(date +%s).png";
        "Alt+Print" = "exec sh -c 'grim -g \"$(slurp)\" ~/Screenshots/screenshot-$(date +%s).png'";

        # Power management
        "${modifier}+Shift+p" = "exec ${pkgs.systemd}/bin/systemctl suspend";

        # Keyboard layout switch - (already using Mod+Shift+Space for floating toggle, skipping)

        # Exit/reload
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Ctrl+Shift+r" = "reload";
      };

      # Bar configuration
      bars = [
        {
          statusCommand = "while :; do echo ''; sleep 1; done";
          command = "waybar";
        }
      ];

      # Startup commands - matching Niri applications
      startup = [
        { command = "mako"; }
        { command = "dms run"; }
        { command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' timeout 600 swaylock timeout 900 '${pkgs.systemd}/bin/systemctl suspend'"; }
        { command = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :1"; }
        { command = "sh -c '${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store'"; }
        { command = "sh -c '${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store'"; }
        { command = "${pkgs.kitty}/bin/kitty"; always = false; }
        { command = "${pkgs.brave}/bin/brave"; always = false; }
        { command = "${pkgs.spotify}/bin/spotify"; always = false; }
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
    cliphist
    grim
    slurp
    xwayland-satellite
    kitty
    spotify
  ];
}
