{
  config,
  lib,
  pkgs,
  vm ? false,
  ...
}:
{
  # Niri window manager configuration
  home.packages = with pkgs; [
    # Core packages for niri
    wofi # Application launcher
    waybar # Status bar
    mako # Notification daemon
    nautilus # File manager
    nemo # Alternative file manager
    fuzzel # Alternative app launcher

    # Screenshot and screen tools
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    swappy # Screenshot editor

    # Wallpaper and theming
    swww # Wayland wallpaper daemon
    pywal # Color scheme generator
    imagemagick # Image processing for pywal

    # Clipboard management
    cliphist # Clipboard history manager

    # Media and audio
    playerctl # Media player control
    pavucontrol # PulseAudio volume control
    pulsemixer # Terminal mixer
    pulseaudio # Audio utilities
    spotify # Music player

    # System utilities
    brightnessctl # Brightness control
    blueman # Bluetooth manager
    networkmanagerapplet # Network manager GUI
    htop # System monitor

    # GNOME dependencies for Nautilus
    gnome-themes-extra
    gsettings-desktop-schemas
    glib
    dconf
  ];

  programs = {
    wofi.enable = true;
    fuzzel.enable = true;
  };

  # Niri configuration
  xdg.configFile."niri/config.kdl".text = ''
    // Niri configuration for user todor

    input {
        keyboard {
            xkb {
                layout "us,bg"
                variant "basic,bas_phonetic"
                options "grp:win_space_toggle"
            }
        }

        touchpad {
            tap
            natural-scroll
            dwt
            dwtp
        }

        mouse {
            accel-speed 0.0
        }

        focus-follows-mouse
    }

    output "eDP-1" {
        mode "2560x1600@60.001"
        scale 1.5
    }

    layout {
        gaps 8
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 2
            active-color "#33ccff"
            inactive-color "#595959"
        }

        border {
            width 2
            active-color "#33ccff"
            inactive-color "#595959"
        }
    }

    prefer-no-csd

    // Startup applications
    spawn-at-startup "sh" "-c" "${pkgs.waybar}/bin/waybar -c $HOME/.config/waybar/config-niri -s $HOME/.config/waybar/style-niri.css"
    spawn-at-startup "${pkgs.mako}/bin/mako"
    spawn-at-startup "${pkgs.swww}/bin/swww-daemon"
    spawn-at-startup "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
    spawn-at-startup "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
    spawn-at-startup "${pkgs.blueman}/bin/blueman-applet"
    spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet"
    spawn-at-startup "${pkgs.ghostty}/bin/ghostty"
    spawn-at-startup "${pkgs.brave}/bin/brave"
    spawn-at-startup "${pkgs.spotify}/bin/spotify"

    environment {
        ELECTRON_OZONE_PLATFORM_HINT "wayland"
        XCURSOR_THEME "Bibata-Modern-Classic"
        XCURSOR_SIZE "24"
        NIXOS_OZONE_WL "1"
    }

    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    screenshot-path "~/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

    hotkey-overlay {
        skip-at-startup
    }

    animations {
        slowdown 1.0

        window-open {
            duration-ms 150
            curve "ease-out-expo"
        }

        window-close {
            duration-ms 150
            curve "ease-out-expo"
        }

        workspace-switch {
            spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
        }

        horizontal-view-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }

        window-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }

        window-resize {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }
    }

    binds {
        // Basic keybindings
        Mod+Return { spawn "${pkgs.ghostty}/bin/ghostty"; }
        Mod+T { spawn "${pkgs.ghostty}/bin/ghostty"; }
        Mod+Shift+Return { spawn "${pkgs.gnome-terminal}/bin/gnome-terminal"; }
        Mod+Q { close-window; }
        Mod+E { spawn "${pkgs.nautilus}/bin/nautilus"; }
        Mod+S { spawn "${pkgs.brave}/bin/brave"; }

        // Application launcher
        Mod+Space { spawn "${pkgs.wofi}/bin/wofi" "--show" "drun"; }
        Mod+Alt+Space { spawn "${pkgs.fuzzel}/bin/fuzzel"; }

        // Window management
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }

        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+K { focus-window-up; }
        Mod+J { focus-window-down; }

        // Move windows
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }

        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+J { move-window-down; }

        // Column width
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        // Move to workspace
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Horizontal workspace switching (scrolling)
        Mod+Ctrl+Left { focus-workspace-down; }
        Mod+Ctrl+Right { focus-workspace-up; }
        Mod+Ctrl+H { focus-workspace-down; }
        Mod+Ctrl+L { focus-workspace-up; }

        // Fullscreen
        Mod+F { fullscreen-window; }

        // Screenshots
        Print { screenshot; }
        Mod+Shift+S { screenshot-screen; }
        Mod+Print { screenshot-window; }

        // Media keys
        XF86AudioRaiseVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        XF86MonBrightnessUp { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "s" "10%+"; }
        XF86MonBrightnessDown { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "s" "10%-"; }

        XF86AudioNext { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
        XF86AudioPause { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioPlay { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioPrev { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }

        // Custom scripts
        Mod+W { spawn "sh" "-c" "$HOME/.config/niri/scripts/wallpaper.sh"; }
        Mod+V { spawn "sh" "-c" "$HOME/.config/niri/scripts/clipboard.sh"; }

        // Exit niri
        Mod+Shift+E { quit; }
    }

    window-rule {
        geometry-corner-radius 10
        clip-to-geometry true
    }
  '';

  # Niri-specific configuration files and scripts
  home.file = {
    # Copy scripts from Hyprland config
    ".config/niri/scripts/wallpaper.sh" = {
      source = ../config/hypr/wallpaper.sh;
      executable = true;
    };
    ".config/niri/scripts/clipboard.sh" = {
      source = ../config/hypr/clipboard.sh;
      executable = true;
    };

    # Waybar configuration for niri
    ".config/waybar/config-niri".text = ''
      {
        "layer": "top",
        "position": "top",
        "margin-bottom": -10,
        "spacing" : 0,

        "modules-left": [
          "niri/workspaces",
          "cpu",
          "memory"
        ],

        "modules-center": ["clock", "clock#sofia"],

        "modules-right": [
          "bluetooth",
          "network",
          "battery",
          "niri/language",
        ],

        "niri/workspaces": {
          "format": "{name}",
        },

        "niri/language": {
          "format": "{short} {variant}",
        },

        "bluetooth": {
          "format": "󰂲",
          "format-on": "{icon}",
          "format-off": "{icon}",
          "format-connected":"{icon}",
          "format-icons":{
              "on":"󰂯",
              "off": "󰂲",
              "connected": "󰂱",
              },
          "on-click": "blueman-manager",
          "tooltip-format-connected":"{device_enumerate}"
        },

        "custom/music": {
          "format": "  {}",
          "escape": true,
          "interval": 5,
          "tooltip": false,
          "exec": "playerctl metadata --format='{{ artist }} - {{ title }}'",
          "on-click": "playerctl play-pause",
          "max-length": 50
        },

        "clock": {
          "timezone": "Europe/Zurich",
          "tooltip": false,
          "format": "{:%H:%M:%S  -  %A, %d}",
          "interval": 1
        },
        "clock#sofia": {
          "timezone": "Europe/Sofia",
          "tooltip": false,
          "format": "{:%H:%M:%S  -  %A, %d}",
          "interval": 1
        },

        "network": {
          "format-wifi": "󰤢",
          "format-ethernet": "󰈀 ",
          "format-disconnected": "󰤠 ",
          "interval": 5,
          "tooltip-format": "{essid} ({signalStrength}%)",
          "on-click": "nm-connection-editor"
        },

        "cpu": {
          "interval": 1,
          "format": "  {icon0}{icon1}{icon2}{icon3} {usage:>2}%",
          "format-icons": ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"],
          "on-click": "ghostty -e htop"
        },

        "memory": {
          "interval": 30,
          "format": "  {used:0.1f}G/{total:0.1f}G",
          "tooltip-format": "Memory"
        },

        "pulseaudio": {
          "format": "{icon}  {volume}%",
          "format-muted": "",
          "format-icons": {
            "default": ["", "", " "]
          },
          "on-click": "pavucontrol"
        },

        "battery": {
              "interval":2,
              "states": {
                  "warning": 30,
                  "critical": 15
              },
              "format": "{icon}  {capacity}%",
              "format-full": "{icon}  {capacity}%",
              "format-charging": " {capacity}%",
              "format-plugged": " {capacity}%",
              "format-alt": "{icon} {time}",
              "format-icons": ["", "", "", "", ""]
        }
      }
    '';

    # Use the same waybar style from Hyprland
    ".config/waybar/style-niri.css" = {
      source = ../config/waybar/style.css;
    };

    # Share wofi config with Hyprland
    ".config/wofi" = {
      source = ../config/wofi;
      recursive = true;
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
