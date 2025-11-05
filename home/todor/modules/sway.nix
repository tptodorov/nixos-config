{
  config,
  lib,
  pkgs,
  vm ? false,
  ...
}:
{
  # Sway window manager configuration
  home.packages = with pkgs; [
    # Core Sway packages
    sway
    swaylock
    swayidle
    swaybg
    # Wayland utilities
    wl-clipboard
    wlr-randr  # Display configuration tool for debugging
    grim
    slurp
    # Application launcher
    wofi
    # Status bar
    waybar
    # Notification daemon
    mako
    # Terminal
    foot
    # File manager
    nautilus
    # Additional utilities
    xdg-utils
    xdg-user-dirs
  ];

  # Sway window manager configuration
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    checkConfig = false; # Disable config validation in Nix sandbox

    config = {
      # Basic configuration
      modifier = "Mod4"; # Super key
      terminal = "foot";
      menu = "wofi --show drun";

      # Window settings
      window = {
        border = 2;
        titlebar = false;
      };

      # Gaps (matching Hyprland VM configuration: gaps_in = 3, gaps_out = 3)
      gaps = {
        inner = 3;
        outer = 3;
      };

      # Colors (matching Hyprland theme)
      colors = {
        focused = {
          border = "#33ccff";
          background = "#33ccff";
          text = "#ffffff";
          indicator = "#33ccff";
          childBorder = "#33ccff";
        };
        unfocused = {
          border = "#595959";
          background = "#595959";
          text = "#ffffff";
          indicator = "#595959";
          childBorder = "#595959";
        };
      };

      # Key bindings
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        # Application shortcuts
        "${modifier}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
        "${modifier}+d" = "exec ${config.wayland.windowManager.sway.config.menu}";
        "${modifier}+b" = "exec brave";

        # Window management
        "${modifier}+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";

        # Focus
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        # Move windows
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

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
        "${modifier}+0" = "workspace number 10";

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
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Layout
        "${modifier}+v" = "splitv";
        "${modifier}+s" = "splith";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";

        # System
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        # Screenshots
        "Print" = "exec grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png";
        "${modifier}+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png";
      };

      # Startup applications
      startup = [
        { command = "waybar"; }
        { command = "mako"; }
        { command = "foot"; }
        { command = "brave"; }
      ] ++ lib.optionals vm [
        # VM-specific startup commands
        { command = "wl-paste --watch cliphist store"; }
      ];

      # Input configuration
      input = {
        "*" = {
          xkb_layout = "us";
          xkb_options = "grp:win_space_toggle";
        };
      };

      # Output configuration
      output = if vm then {
        "*" = {
          # VM configuration - explicit high resolution mode with 2x scaling
          # Using 2560x1600 which is available and provides good scaling
          mode = "2560x1600@60Hz";
          scale = "1.5";
          # This gives effective resolution of 1280x800 with crisp scaling
        };
      } else {
        "*" = {
          mode = "preferred";
          scale = "1.5";
        };
      };

      # Bars (disable default, use waybar)
      bars = [];
    };

    # Extra configuration
    extraConfig = ''
      # VM-specific environment variables
      ${lib.optionalString vm ''
        exec_always export WLR_NO_HARDWARE_CURSORS=1
        exec_always export __GLX_VENDOR_LIBRARY_NAME=mesa
        exec_always export LIBGL_ALWAYS_INDIRECT=0
        exec_always export LIBGL_ALWAYS_SOFTWARE=0
        exec_always export MESA_LOADER_DRIVER_OVERRIDE=vmwgfx
        # Note: GDK_SCALE, QT_SCALE_FACTOR etc. are set system-wide in desktop.nix
      ''}

      # Wayland environment
      exec_always export NIXOS_OZONE_WL=1
      exec_always export ELECTRON_OZONE_PLATFORM_HINT=wayland
      exec_always export XCURSOR_THEME=Bibata-Modern-Classic
      exec_always export XCURSOR_SIZE=24

      # Auto-start applications on specific workspaces
      assign [app_id="foot"] workspace 1
      assign [class="Brave-browser"] workspace 1

      # Floating windows
      for_window [app_id="nautilus"] floating enable
      for_window [class="Nautilus"] floating enable
    '';
  };

  # Services
  services = {
    # Notification daemon
    mako = {
      enable = true;
      settings = {
        sort = "-time";
        layer = "top";
        background-color = "#22348e";
        width = "300";
        height = "150";
        "border-size" = "0";
        "border-color" = "#72B2FE";
        "border-radius" = "15";
        padding = "20";
        icons = "1";
        "max-icon-size" = "64";
        "default-timeout" = "5000";
        "ignore-timeout" = "1";
        font = "Millimetre 10";
      };
    };
  };

  # Programs
  programs = {
    wofi.enable = true;
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          margin-bottom = -10;
          spacing = 0;

          modules-left = [
            "sway/workspaces"
            "cpu"
            "memory"
          ];

          modules-center = [ "clock" "clock#sofia" ];

          modules-right = [
            "bluetooth"
            "network"
            "battery"
            "sway/language"
          ];

          "sway/workspaces" = {
            format = "{name}: {icon}";
            format-icons = {
              active = "";
              default = "";
            };
          };

          "sway/language" = {
            format = "{short} {variant}";
          };

          bluetooth = {
            format = "󰂲";
            format-on = "{icon}";
            format-off = "{icon}";
            format-connected = "{icon}";
            format-icons = {
              on = "󰂯";
              off = "󰂲";
              connected = "󰂱";
            };
            on-click = "blueman-manager";
            tooltip-format-connected = "{device_enumerate}";
          };

          clock = {
            timezone = "Europe/Zurich";
            tooltip = false;
            format = "{:%H:%M:%S  -  %A, %d}";
            interval = 1;
          };

          "clock#sofia" = {
            timezone = "Europe/Sofia";
            tooltip = false;
            format = "{:%H:%M:%S  -  %A, %d}";
            interval = 1;
          };

          network = {
            format-wifi = "󰤢";
            format-ethernet = "󰈀 ";
            format-disconnected = "󰤠 ";
            interval = 5;
            tooltip-format = "{essid} ({signalStrength}%)";
            on-click = "nm-connection-editor";
          };

          cpu = {
            interval = 1;
            format = "  {icon0}{icon1}{icon2}{icon3} {usage:>2}%";
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            on-click = "foot -e htop";
          };

          memory = {
            interval = 30;
            format = "  {used:0.1f}G/{total:0.1f}G";
            tooltip-format = "Memory";
          };

          battery = {
            interval = 2;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon}  {capacity}%";
            format-full = "{icon}  {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["" "" "" "" ""];
          };
        };
      };
    };
  };

  # Wayland and GNOME environment variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # GNOME/GTK settings for Nautilus
    GTK_USE_PORTAL = "1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  };

  # Enable dconf for GNOME apps
  dconf.enable = true;
}
