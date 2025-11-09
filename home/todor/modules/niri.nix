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

    # Screenshot and screen tools
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    swappy # Screenshot editor

    # Wallpaper and theming
    swww # Wayland wallpaper daemon

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
    swayidle # Idle timeout manager
    swaylock # Screen locker

    # GNOME dependencies for Nautilus and secrets management
    gnome-themes-extra
    gsettings-desktop-schemas
    glib
    dconf
    gnome-keyring # Keyring daemon
    libsecret # Secret storage library
  ];

  programs = {
    wofi.enable = true;
  };

  # Niri configuration
  xdg.configFile."niri/config.kdl".text = ''
    // Niri configuration for user todor
    workspace "chat"

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
        }

        focus-follows-mouse
    }

    output "eDP-1" {
        mode "2560x1600@60.001"
        scale 1.5
    }

    layout {
        gaps 8

        focus-ring {
            width 2
            active-color "#7aa2f7"
            inactive-color "#414868"
        }

        border {
            width 2
            active-color "#7aa2f7"
            inactive-color "#1f2335"
        }
    }

    prefer-no-csd

    // Window rules
    window-rule {
    }

    window-rule {
        match app-id="com.viber.Viber"
        match title="WasIstLos"
        match title="viber"

        open-on-workspace "chat"
    }


    // Startup applications
    spawn-at-startup "sh" "-c" "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    spawn-at-startup "sh" "-c" "$HOME/.config/niri/scripts/keyring-init.sh"
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
    spawn-at-startup "${pkgs.viber}/bin/viber"
    spawn-at-startup "${pkgs.wasistlos}/bin/wasistlos"

    // Idle management: dim screen after 5min, suspend after 10min
    spawn-at-startup "${pkgs.swayidle}/bin/swayidle" "-w" "timeout" "300" "${pkgs.brightnessctl}/bin/brightnessctl set 10%" "resume" "${pkgs.brightnessctl}/bin/brightnessctl set 100%" "timeout" "600" "${pkgs.systemd}/bin/systemctl suspend"

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

    binds {
        // Basic keybindings
        Super+Return { spawn "${pkgs.ghostty}/bin/ghostty"; }
        Super+T { spawn "${pkgs.ghostty}/bin/ghostty"; }
        Super+Q { close-window; }
        Super+E { spawn "${pkgs.nautilus}/bin/nautilus"; }
        Super+S { spawn "${pkgs.brave}/bin/brave"; }
        Super+Shift+A { spawn "${pkgs.mailspring}/bin/mailspring" "--password-store=gnome-libsecret" "--disable-gpu"; }

        // Application launcher
        Super+D { spawn "${pkgs.wofi}/bin/wofi" "--show" "drun"; }

        // Window management (vim-style)
        Super+H { focus-column-left; }
        Super+L { focus-column-right; }
        Super+K { focus-window-up; }
        Super+J { focus-window-down; }

        // Window management (arrow keys)
        Super+Left { focus-column-left; }
        Super+Right { focus-column-right; }
        Super+Up { focus-window-up; }
        Super+Down { focus-window-down; }

        // Move windows (vim-style)
        Super+Shift+H { move-column-left; }
        Super+Shift+L { move-column-right; }
        Super+Shift+K { move-window-up; }
        Super+Shift+J { move-window-down; }

        // Move windows (arrow keys)
        Super+Shift+Left { move-column-left; }
        Super+Shift+Right { move-column-right; }
        Super+Shift+Up { move-window-up; }
        Super+Shift+Down { move-window-down; }

        // Consume/expel windows (merge/unmerge columns)
        Super+Ctrl+H { consume-or-expel-window-left; }
        Super+Ctrl+L { consume-or-expel-window-right; }
        Super+Ctrl+Left { consume-or-expel-window-left; }
        Super+Ctrl+Right { consume-or-expel-window-right; }
        Super+BracketLeft { consume-window-into-column; }
        Super+BracketRight { expel-window-from-column; }

        // Center windows/columns
        Super+C { center-column; }
        Super+Shift+C { center-window; }
        Super+Alt+C { center-visible-columns; }

        // Column width management
        Super+R { switch-preset-column-width; }
        Super+Ctrl+R { switch-preset-column-width-back; }
        Super+M { maximize-column; }
        Super+Shift+M { expand-column-to-available-width; }
        Super+Equal { set-column-width "+10%"; }
        Super+Minus { set-column-width "-10%"; }

        // Window width/height management
        Super+Ctrl+Equal { set-window-height "+10%"; }
        Super+Ctrl+Minus { set-window-height "-10%"; }
        Super+Shift+Equal { reset-window-height; }

        // Workspaces
        Super+1 { focus-workspace 1; }
        Super+2 { focus-workspace 2; }
        Super+3 { focus-workspace 3; }
        Super+4 { focus-workspace 4; }
        Super+5 { focus-workspace 5; }
        Super+6 { focus-workspace 6; }
        Super+7 { focus-workspace 7; }
        Super+8 { focus-workspace 8; }
        Super+9 { focus-workspace 9; }

        // Workspace navigation
        Super+Page_Down { focus-workspace-down; }
        Super+Page_Up { focus-workspace-up; }
        Super+U { focus-workspace-down; }
        Super+I { focus-workspace-up; }
        Super+Tab { focus-workspace-previous; }

        // Move window to workspace
        Super+Shift+1 { move-column-to-workspace 1; }
        Super+Shift+2 { move-column-to-workspace 2; }
        Super+Shift+3 { move-column-to-workspace 3; }
        Super+Shift+4 { move-column-to-workspace 4; }
        Super+Shift+5 { move-column-to-workspace 5; }
        Super+Shift+6 { move-column-to-workspace 6; }
        Super+Shift+7 { move-column-to-workspace 7; }
        Super+Shift+8 { move-column-to-workspace 8; }
        Super+Shift+9 { move-column-to-workspace 9; }
        Super+Shift+Page_Down { move-column-to-workspace-down; }
        Super+Shift+Page_Up { move-column-to-workspace-up; }
        Super+Shift+U { move-column-to-workspace-down; }
        Super+Shift+I { move-column-to-workspace-up; }

        // Move entire workspace between monitors (multi-monitor setups)
        Super+Ctrl+Shift+Left { move-workspace-to-monitor-left; }
        Super+Ctrl+Shift+Right { move-workspace-to-monitor-right; }
        Super+Ctrl+Shift+Up { move-workspace-to-monitor-up; }
        Super+Ctrl+Shift+Down { move-workspace-to-monitor-down; }

        // Fullscreen and tabbed mode
        Super+F { fullscreen-window; }
        Super+Shift+F { toggle-windowed-fullscreen; }
        Super+Alt+T { toggle-column-tabbed-display; }

        // Floating windows
        Super+Shift+F10 { toggle-window-floating; }
        Super+Alt+F { focus-floating; }
        Super+Alt+Shift+F { focus-tiling; }
        Super+Ctrl+Space { switch-focus-between-floating-and-tiling; }

        // Screenshots
        Print { screenshot; }
        Super+Print { screenshot-screen; }
        Super+Shift+S { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // Media keys
        XF86AudioRaiseVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        XF86MonBrightnessUp { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "s" "10%+"; }
        XF86MonBrightnessDown { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "s" "10%-"; }

        XF86AudioPlay { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioNext { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
        XF86AudioPrev { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }

        // Custom scripts
        Super+W { spawn "sh" "-c" "$HOME/.config/niri/scripts/wallpaper.sh"; }
        Super+V { spawn "sh" "-c" "$HOME/.config/niri/scripts/clipboard.sh"; }

        // Overview mode
        Super+O { toggle-overview; }

        // Power management
        Super+Shift+P { spawn "${pkgs.systemd}/bin/systemctl" "suspend"; }
        Super+Alt+P { power-off-monitors; }

        // Screen lock
        Super+Escape { spawn "${pkgs.swaylock}/bin/swaylock"; }

        // Switch keyboard layout
        Super+Shift+Space { switch-layout "next"; }

        // Show hotkey overlay
        Super+Slash { show-hotkey-overlay; }
        Super+Shift+Slash { show-hotkey-overlay; }

        // Exit niri
        Super+Shift+E { quit; }

        // Reload config
        Super+Ctrl+Shift+R { spawn "sh" "-c" "niri msg action load-config-file"; }
    }
  '';

  # Niri-specific configuration files and scripts
  home.file = {
    # Gnome keyring initialization script
    ".config/niri/scripts/keyring-init.sh" = {
      text = ''
        #!/bin/sh
        # Kill any existing gnome-keyring-daemon instances
        ${pkgs.procps}/bin/pkill -f gnome-keyring-daemon 2>/dev/null
        sleep 0.5

        # Start gnome-keyring-daemon and export the environment variables
        eval $(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null)
        export SSH_AUTH_SOCK
        export GNOME_KEYRING_CONTROL
        export GNOME_KEYRING_PID

        # Update systemd and dbus environments
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID

        # Log for debugging
        echo "Keyring initialized: GNOME_KEYRING_CONTROL=$GNOME_KEYRING_CONTROL SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
      '';
      executable = true;
    };

    # Copy scripts from Hyprland config
    ".config/niri/scripts/wallpaper.sh".text = ''
      #!/bin/bash
      # Please place your wallpaper at ~/.config/niri/wallpaper.png
      WALLPAPER_PATH="$HOME/.config/niri/wallpaper.png"

      if [ -f "$WALLPAPER_PATH" ]; then
          swww img "$WALLPAPER_PATH" --transition-type any --transition-fps 60 --transition-duration .5
      else
          # You can add a fallback wallpaper here
          # For example, you can set a solid color background
          swww img "#24283b" --transition-type any --transition-fps 60 --transition-duration .5
      fi
    '';
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
          "custom/music",
          "pulseaudio",
          "bluetooth",
          "network",
          "battery",
          "niri/language"
        ],

        "niri/workspaces": {
          "format": "{index}",
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
          "format": "Zurich: {:%H:%M:%S  -  %A, %d}",
          "interval": 1
        },
        "clock#sofia": {
          "timezone": "Europe/Sofia",
          "tooltip": false,
          "format": "Sofia: {:%H:%M:%S  -  %A, %d}",
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
          "format-muted": "  {volume}%",
          "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
          },
          "on-click": "pavucontrol",
          "scroll-step": 1,
          "ignored-sinks": []
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

    # Tokyo Night Storm themed waybar style
    ".config/waybar/style-niri.css".text = ''
      /* Tokyo Night Storm Theme for Waybar */
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 13px;
        min-height: 0;
        padding-right: 0px;
        padding-left: 0px;
        padding-bottom: 0px;
      }

      #waybar {
        background: transparent;
        color: #c0caf5;
        margin: 0px;
        font-weight: 500;
      }

      /* Left Modules */
      #workspaces,
      #cpu,
      #memory {
        background-color: #24283b;
        padding: 0.3rem 0.7rem;
        margin: 5px 0px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        min-width: 0;
        border: 1px solid #414868;
        transition: all 0.2s ease-in-out;
      }

      #workspaces {
        padding: 2px;
        margin-left: 7px;
        margin-right: 5px;
      }

      #cpu:hover,
      #memory:hover {
        background-color: #292e42;
        border-color: #7aa2f7;
      }

      #workspaces button {
        color: #a9b1d6;
        border-radius: 6px;
        padding: 0.3rem 0.6rem;
        background: transparent;
        transition: all 0.2s ease-in-out;
        border: none;
        outline: none;
      }

      #workspaces button.active {
        color: #7aa2f7;
        background-color: rgba(122, 162, 247, 0.15);
        box-shadow: inset 0 0 0 1px rgba(122, 162, 247, 0.3);
      }

      #workspaces button:hover {
        background: #292e42;
        color: #c0caf5;
      }

      /* Center Modules */
      #clock {
        background-color: #24283b;
        padding: 0.3rem 0.7rem;
        margin: 5px 5px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(122, 162, 247, 0.2);
        min-width: 0;
        border: 1px solid #414868;
        transition: all 0.2s ease-in-out;
        color: #7aa2f7;
        font-weight: 600;
      }

      #clock:hover {
        background-color: rgba(122, 162, 247, 0.15);
        border-color: #7aa2f7;
      }

      /* Right Modules - Seamless Bar */
      #custom-music,
      #pulseaudio,
      #bluetooth,
      #network,
      #battery,
      #language {
        background-color: #24283b;
        padding: 0.3rem 0.7rem;
        margin: 5px 0px;
        border-radius: 0;
        box-shadow: none;
        min-width: 0;
        border-top: 1px solid #414868;
        border-bottom: 1px solid #414868;
        transition: all 0.2s ease-in-out;
      }

      #custom-music:hover,
      #pulseaudio:hover,
      #bluetooth:hover,
      #network:hover,
      #battery:hover,
      #language:hover {
        background-color: #292e42;
      }

      #custom-music {
        margin-left: 5px;
        border-left: 1px solid #414868;
        border-top-left-radius: 8px;
        border-bottom-left-radius: 8px;
        color: #bb9af7;
      }

      #language {
        border-right: 1px solid #414868;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        margin-right: 7px;
        color: #7dcfff;
      }

      #cpu {
        color: #f7768e;
      }

      #memory {
        color: #9ece6a;
      }

      #pulseaudio {
        color: #7dcfff;
      }

      #bluetooth {
        color: #565f89;
        font-size: 16px;
      }

      #bluetooth.on {
        color: #7aa2f7;
      }

      #bluetooth.connected {
        color: #7dcfff;
      }

      #network {
        color: #c0caf5;
      }

      #network.disconnected {
        color: #f7768e;
      }

      #battery {
        color: #9ece6a;
      }

      #battery.charging {
        color: #73daca;
      }

      #battery.warning:not(.charging) {
        color: #e0af68;
      }

      #battery.critical:not(.charging) {
        color: #f7768e;
      }

      /* Tooltip */
      tooltip {
        background-color: #1f2335;
        color: #c0caf5;
        padding: 8px 14px;
        margin: 5px 0px;
        border-radius: 8px;
        border: 1px solid #414868;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        font-size: 12px;
      }
    '';

    # Mako configuration for niri
    ".config/mako/config".text = ''
      font=JetBrainsMono Nerd Font 10
      background-color=#24283b
      text-color=#c0caf5
      border-color=#7aa2f7
      border-size=2
      border-radius=8
      default-timeout=5000
      layer=overlay
    '';

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
