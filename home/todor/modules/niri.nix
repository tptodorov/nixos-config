{
  config,
  lib,
  pkgs,
  vm ? false,
  laptop ? false,
  ...
}:
{
  # Niri window manager configuration
  home.packages = with pkgs; [
    nautilus # File manager
    nemo # Alternative file manager

    # System utilities
    brightnessctl # Brightness control
    blueman # Bluetooth manager
    networkmanagerapplet # Network manager GUI
    htop # System monitor
    swayidle # Idle timeout manager
    xwayland-satellite # X11 compatibility for Wayland (for snaps and X11 apps)

    # GNOME dependencies for Nautilus and secrets management
    gnome-themes-extra
    gsettings-desktop-schemas
    glib
    dconf
    gnome-keyring # Keyring daemon
    libsecret # Secret storage library

    swappy # screenshot editor
  ];

  # Niri configuration
  xdg.configFile."niri/config.kdl".text = ''
    include "dms/binds.kdl"
    // Niri configuration for user todor
    workspace "chat" {}
    workspace "browse" {}
    workspace "dev" {}

    input {
        keyboard {
            xkb {
                layout "us,bg"
                variant "basic,phonetic"
                options "grp:rwin_toggle"
            }
        }

        touchpad {
            tap
        }
    }

    layer-rule {
        match namespace="dms:blurwallpaper"
        place-within-backdrop true
    }

    output "eDP-1" {
        mode "2560x1600@60.001"
        scale 2.0
    }

    prefer-no-csd

    // Window rules
    window-rule {
      match app-id="brave-browser"
      match app-id="spotify"
      match app-id="geary"
      match at-startup=true
      open-on-workspace "browse"
    }

    window-rule {
        match app-id="com.viber.Viber"
        match app-id="wasistlos"
        match title="WasIstLos"
        match title="viber"

        open-on-workspace "chat"
        open-focused false
    }

    window-rule {
        match app-id=r#"^org\.gnome\."#
        draw-border-with-background false
        geometry-corner-radius 12
        clip-to-geometry true
    }

    window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        match app-id="Alacritty"
        match app-id="zen"
        match app-id="com.mitchellh.ghostty"
        match app-id="kitty"
        draw-border-with-background false
    }

    window-rule {
        match is-active=false
        opacity 0.9
    }

    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
    }

    // Startup applications
    spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite" ":1" // X11 server for snaps and X11 apps
    spawn-at-startup "sh" "-c" "dms ipc wallpaper set ~/.config/asset/3.jpg"
    spawn-at-startup "sh" "-c" "$HOME/.config/niri/scripts/keyring-init.sh"
    spawn-at-startup "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
    spawn-at-startup "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
    spawn-at-startup "${pkgs.ghostty}/bin/ghostty"
    spawn-at-startup "${pkgs.brave}/bin/brave"
    spawn-at-startup "${pkgs.spotify}/bin/spotify"
    spawn-at-startup "${pkgs.viber}/bin/viber"
    spawn-at-startup "${pkgs.wasistlos}/bin/wasistlos"
    // (Optional) replace with a polkit agent for escalation prompts
    // spawn-at-startup "{{POLKIT_AGENT_PATH}}"

    environment {
        DISPLAY ":1" // X11 display for XWayland apps and snaps
        XCURSOR_THEME "Bibata-Modern-Classic"
        XCURSOR_SIZE "24"
        NIXOS_OZONE_WL "1"
          XDG_CURRENT_DESKTOP "niri"
          QT_QPA_PLATFORM "wayland"
          ELECTRON_OZONE_PLATFORM_HINT "auto"
          QT_QPA_PLATFORMTHEME "gtk3"
          QT_QPA_PLATFORMTHEME_QT6 "gtk3"
          DMS_SCREENSHOT_EDITOR "swappy"
    }

    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    screenshot-path "~/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

    binds {
        // Basic keybindings
        Super+Return { spawn "${pkgs.ghostty}/bin/ghostty"; }
        Super+T { spawn "${pkgs.ghostty}/bin/ghostty"; }
        Super+Q { close-window; }
        Super+E { spawn "${pkgs.nautilus}/bin/nautilus"; }
        Super+S { spawn "${pkgs.brave}/bin/brave"; }
        Super+A { spawn "${pkgs.geary}/bin/geary"; }

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
        Print { spawn "dms" "ipc" "niri" "screenshot"; }
        Super+Print { spawn "dms" "ipc" "niri" "screenshotScreen"; }
        Alt+Print { spawn "dms" "ipc" "niri" "screenshotWindow"; }

        // Overview mode
        Super+O { toggle-overview; }

        // Power management
        Super+Shift+P { spawn "${pkgs.systemd}/bin/systemctl" "suspend"; }
        Super+Alt+P { power-off-monitors; }

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


    include "dms/colors.kdl"
    include "dms/layout.kdl"
    include "dms/wpblur.kdl"
  '';

  # Niri-specific configuration files and scripts
  home.file = {
    # Electron flags for proper HiDPI scaling on Wayland
    ".config/electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform,WaylandWindowDecorations
      --ozone-platform=wayland
      ${lib.optionalString laptop "--force-device-scale-factor=2.0"}
    '';

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

    # DMS bindings for application launcher and system controls
    ".config/niri/dms/binds.kdl".text = ''
      binds {
          Mod+Space hotkey-overlay-title="Application Launcher" {
              spawn "dms" "ipc" "call" "spotlight" "toggle";
          }

          Mod+V hotkey-overlay-title="Clipboard Manager" {
              spawn "dms" "ipc" "call" "clipboard" "toggle";
          }

          Mod+M hotkey-overlay-title="Task Manager" {
              spawn "dms" "ipc" "call" "processlist" "toggle";
          }

          Mod+Comma hotkey-overlay-title="Settings" {
              spawn "dms" "ipc" "call" "settings" "toggle";
          }

          Mod+N hotkey-overlay-title="Notification Center" {
              spawn "dms" "ipc" "call" "notifications" "toggle";
          }

          Mod+Y hotkey-overlay-title="Browse Wallpapers" {
              spawn "dms" "ipc" "call" "dankdash" "wallpaper";
          }

          Mod+Shift+N hotkey-overlay-title="Notepad" {
            spawn "dms" "ipc" "call" "notepad" "toggle";
          }

          Mod+Alt+L hotkey-overlay-title="Lock Screen" {
              spawn "dms" "ipc" "call" "lock" "lock";
          }

          Ctrl+Alt+Delete hotkey-overlay-title="Task Manager" {
              spawn "dms" "ipc" "call" "processlist" "toggle";
          }

          // Audio
          XF86AudioRaiseVolume allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "increment" "3";
          }
          XF86AudioLowerVolume allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "decrement" "3";
          }
          XF86AudioMute allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "mute";
          }
          XF86AudioMicMute allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "micmute";
          }

          // BL
          XF86MonBrightnessUp allow-when-locked=true {
             spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
          }
          XF86MonBrightnessDown allow-when-locked=true {
             spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
          }
      }
    '';

    # Asset folder for desktop access
    ".config/asset".source = ../config/asset;

  };
  # Wayland and GNOME environment variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # GNOME/GTK settings for Nautilus
    GTK_USE_PORTAL = "1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  }
  // lib.optionalAttrs laptop {
    # HiDPI scaling for GTK apps on laptop (2x scaling = GDK_SCALE 2 * GDK_DPI_SCALE 1.0)
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1.0";
  };

  # Enable dconf for GNOME apps
  dconf.enable = true;
}
