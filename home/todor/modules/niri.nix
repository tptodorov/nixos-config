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
  # NOTE: Application packages are defined in desktop-apps.nix and other topic-based modules

  # Niri configuration
  xdg.configFile."niri/config.kdl".text = ''
    // Niri configuration for user todor
    // NOTE: When disconnecting external monitors, press Super+1 (or any workspace number)
    // to switch focus to a workspace on the remaining display
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

    // Laptop built-in display
    output "Samsung Display Corp. ATNA40HQ01-0  Unknown" {
        mode "2880x1800@120.000000"
        scale 2.0
    }

    // External monitor (when connected) - automatically configured
    // Niri will auto-detect and position external displays

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
      match title="Mail"
      match title="Calendar"
      match app-id=r#"calendar"#
      match app-id=r#"mail"#
      open-on-workspace "chat"
    }

    window-rule {
        match app-id=r#"Viber"#
        match title="viber"

        open-on-workspace "chat"
        open-focused false
        default-column-width { proportion 0.5; }
        min-width 800
        min-height 600
    }

    window-rule {
        match app-id="wasistlos"
        match title="WasIstLos"

        open-on-workspace "chat"
        open-focused false
    }

    window-rule {
        match app-id="zoom"
        match title="Zoom"

        match app-id="slack"
        match title="Slack"

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
    spawn-at-startup "dms" "run"
    spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite" ":1" // X11 server for snaps and X11 apps
    spawn-at-startup "sh" "-c" "dms ipc wallpaper set ~/.config/asset/3.jpg"
    spawn-at-startup "sh" "-c" "$HOME/.config/niri/scripts/ssh-agent-init.sh"
    spawn-at-startup "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
    spawn-at-startup "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
    spawn-at-startup "${pkgs.kitty}/bin/kitty"
    spawn-at-startup "${pkgs.brave}/bin/brave"
    spawn-at-startup "${pkgs.spotify}/bin/spotify"
    spawn-at-startup "sh" "-c" "env GDK_SCALE=2 GDK_DPI_SCALE=1 ${pkgs.viber}/bin/viber"
    spawn-at-startup "sh" "-c" "env GDK_SCALE=2 GDK_DPI_SCALE=1 ${pkgs.wasistlos}/bin/wasistlos"
    // spawn-at-startup "${pkgs.brave}/bin/brave" "--app=https://mail.notion.so/"
    // spawn-at-startup "${pkgs.brave}/bin/brave" "--app=https://calendar.notion.so/"

    // Idle management - screen off after 5 min, lock after 10 min, suspend after 15 min
    spawn-at-startup "${pkgs.swayidle}/bin/swayidle" "-w" \
      "timeout" "300" "niri msg action power-off-monitors" \
      "resume" "niri msg action power-on-monitors" \
      "timeout" "600" "swaylock" \
      "timeout" "900" "${pkgs.systemd}/bin/systemctl suspend"

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
          }

    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    screenshot-path "~/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

    binds {
        // Universal clipboard (Omarchy-style)
        Super+C hotkey-overlay-title="Copy" { spawn "${pkgs.wtype}/bin/wtype" "-M" "ctrl" "c" "-m" "ctrl"; }
        Super+X hotkey-overlay-title="Cut" { spawn "${pkgs.wtype}/bin/wtype" "-M" "ctrl" "x" "-m" "ctrl"; }
        Super+V hotkey-overlay-title="Paste" { spawn "${pkgs.wtype}/bin/wtype" "-M" "ctrl" "v" "-m" "ctrl"; }

        // Basic keybindings
        Super+Return hotkey-overlay-title="Terminal" { spawn "${pkgs.kitty}/bin/kitty"; }
        Super+Q { close-window; }
        Super+E hotkey-overlay-title="File Manager" { spawn "${pkgs.nautilus}/bin/nautilus"; }
        Super+S hotkey-overlay-title="Web Browser" { spawn "${pkgs.brave}/bin/brave"; }
        Super+A hotkey-overlay-title="Email Client" { spawn "${pkgs.brave}/bin/brave" "--app=https://mail.notion.so/" ; }

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
        Super+Shift+C { center-column; }
        Super+Ctrl+Shift+C { center-window; }
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

        // Multi-monitor support
        // Focus different monitor
        Super+Alt+H { focus-monitor-left; }
        Super+Alt+L { focus-monitor-right; }
        Super+Alt+K { focus-monitor-up; }
        Super+Alt+J { focus-monitor-down; }
        Super+Alt+Left { focus-monitor-left; }
        Super+Alt+Right { focus-monitor-right; }
        Super+Alt+Up { focus-monitor-up; }
        Super+Alt+Down { focus-monitor-down; }

        // Recovery: Focus workspace 1 (useful when external monitor disconnects)
        Super+Home hotkey-overlay-title="Focus Workspace 1" { focus-workspace 1; }

        // Move window to different monitor
        Super+Shift+Alt+H { move-column-to-monitor-left; }
        Super+Shift+Alt+L { move-column-to-monitor-right; }
        Super+Shift+Alt+K { move-column-to-monitor-up; }
        Super+Shift+Alt+J { move-column-to-monitor-down; }
        Super+Shift+Alt+Left { move-column-to-monitor-left; }
        Super+Shift+Alt+Right { move-column-to-monitor-right; }
        Super+Shift+Alt+Up { move-column-to-monitor-up; }
        Super+Shift+Alt+Down { move-column-to-monitor-down; }

        // Move entire workspace between monitors
        Super+Ctrl+Shift+H { move-workspace-to-monitor-left; }
        Super+Ctrl+Shift+L { move-workspace-to-monitor-right; }
        Super+Ctrl+Shift+K { move-workspace-to-monitor-up; }
        Super+Ctrl+Shift+J { move-workspace-to-monitor-down; }
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

        // Screenshots with grim and slurp
        Print { spawn "grim" "-o" "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" "~/Screenshots/screenshot-$(date +%s).png"; }
        Super+Print { spawn "grim" "~/Screenshots/screenshot-$(date +%s).png"; }
        Alt+Print { spawn "sh" "-c" "grim -g \"$(slurp)\" ~/Screenshots/screenshot-$(date +%s).png"; }

        // Overview mode
        Super+O { toggle-overview; }

        // Power management
        Super+Shift+P hotkey-overlay-title="Suspend" { spawn "${pkgs.systemd}/bin/systemctl" "suspend"; }
        Super+Alt+P { power-off-monitors; }

        // Switch keyboard layout
        Super+Shift+Space { switch-layout "next"; }

        // Show hotkey overlay
        Super+Slash { show-hotkey-overlay; }
        Super+Shift+Slash { show-hotkey-overlay; }

        // Exit niri
        Super+Shift+E { quit; }

        // Reload config
        Super+Ctrl+Shift+R hotkey-overlay-title="Reload Config" { spawn "sh" "-c" "niri msg action load-config-file"; }
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

    # SSH agent initialization script (gnome-keyring removed)
    ".config/niri/scripts/ssh-agent-init.sh" = {
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

    # DMS bindings for application launcher and system controls
    ".config/niri/dms/binds.kdl".text = ''
      binds {
          Mod+Space hotkey-overlay-title="Application Launcher" {
              spawn "dms" "ipc" "call" "spotlight" "toggle";
          }

          Mod+Shift+V hotkey-overlay-title="Clipboard History" {
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
}
