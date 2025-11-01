{
  config,
  lib,
  pkgs,
  vm ? false,
  ...
}:
{
  # Hyprland desktop environment configuration
  home.packages = with pkgs; [
    wofi
    gnome-terminal  # Backup terminal
    # Core packages for both VM and blackbox
    waybar
    mako
    nautilus
    grim
    slurp
  ] ++ lib.optionals vm [
    foot  # VM-specific terminal
  ] ++ lib.optionals (!vm) [
    # Full desktop packages (disabled in VMs for simplicity)
    pyprland
    pulseaudio
    hyprshot
    cliphist
    swappy
    grim
    slurp
    hyprpaper
    hypridle
  ];

  programs = {
    wofi.enable = true;
  } // lib.optionalAttrs (!vm) {
    hyprlock.enable = true;
    waybar.enable = true;
    waylogout.enable = true;
    wayprompt.enable = true;
  };

  services = {
    # Hyprland services
    hyprsunset.enable = true;
    hyprpaper.enable = true;
    playerctld.enable = true;

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

  # Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    extraConfig = if vm then ''
      # VM Configuration - MacBook Pro 14" 2025 display (3024x1964)
      monitor =,3024x1964@120,auto,2

      # Basic variables - matching blackbox style
      $color9=rgba(33ccffee)
      $color5=rgba(595959aa)
      $terminal = foot
      $fileManager = nautilus
      $browser = brave
      $menu = wofi --show drun

      # VM-optimized exec-once (minimal startup)
      exec-once = sleep 1 && waybar
      exec-once = sleep 1 && mako
      exec-once = sleep 2 && [workspace 1 silent] $terminal
      exec-once = sleep 3 && [workspace 1 silent] $browser

      # Environment variables - matching blackbox
      env = ELECTRON_OZONE_PLATFORM_HINT,wayland
      env = XCURSOR_THEME,Bibata-Modern-Classic
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24

      # General settings - closer to blackbox but VM-optimized
      general {
          gaps_in = 3
          gaps_out = 3
          border_size = 2
          col.active_border = $color9
          col.inactive_border = $color5
          resize_on_border = true
          allow_tearing = false
          layout = dwindle
      }

      # Minimal animations for VM performance
      animations {
          enabled = true
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 3, myBezier
          animation = windowsOut, 1, 3, default, popin 80%
          animation = border, 1, 5, default
          animation = borderangle, 1, 4, default
          animation = fade, 1, 3, default
          animation = workspaces, 1, 3, default
      }

      decoration {
          rounding = 5
          active_opacity = 1.0
          inactive_opacity = 1.0
          fullscreen_opacity = 1.0
          blur {
              enabled = false  # Disabled for VM performance
          }
          shadow {
              enabled = false  # Disabled for VM performance
          }
      }

      input {
          kb_layout = us
          follow_mouse = 1
      }

      # Super simple keybindings
      $mainMod = SUPER
      bind = $mainMod, Return, exec, foot
      bind = $mainMod, T, exec, foot
      bind = $mainMod SHIFT, Return, exec, alacritty
      bind = $mainMod SHIFT, T, exec, gnome-terminal
      bind = $mainMod, Q, killactive
      bind = $mainMod, Space, exec, wofi --show drun
      bind = $mainMod, M, exit

      # Basic window management
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Just 3 workspaces for testing
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3

      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3

      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '' else ''
      # Full Configuration for Physical Machines
      monitor =,preferred,auto,1.5

      #colors
      $color9=rgba(33ccffee)
      $color5=rgba(595959aa)
      $terminal = ghostty
      $fileManager = nautilus
      $browser = brave
      $menu = wofi --show drun

      exec-once = sleep 1 && hypridle
      exec-once = sleep 2 && waybar
      exec-once = sleep 1 && mako
      exec-once = sleep 2 && pypr --debug
      exec-once = sleep 1 && pactl set-sink-mute @DEFAULT_SINK@ 0
      exec-once = sleep 2 && hyprpaper
      exec-once = sleep 2 && hyprsunset
      exec-once = sleep 4 && [workspace 1 silent] $terminal
      exec-once = sleep 5 && [workspace 1 silent] $browser
      exec-once = sleep 6 && [workspace 1 silent] spotify
      exec-once = sleep 3 && wl-paste --type text --watch cliphist store
      exec-once = sleep 3 && wl-paste --type image --watch cliphist store

      env = ELECTRON_OZONE_PLATFORM_HINT,wayland
      env = XCURSOR_THEME,Bibata-Modern-Classic
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24

      general {

              gaps_in = 5
                  gaps_out = 5
                  border_size = 2
                  col.active_border = $color9
                  col.inactive_border = $color5
                  resize_on_border = true
                  allow_tearing = false
                  layout = dwindle
      }
      decoration {
          rounding = 10
              active_opacity = 0.78
              inactive_opacity = 0.7
              fullscreen_opacity = 1
              blur {
                  enabled = true
                      size = 3
                      passes = 5
                      new_optimizations = true
                      ignore_opacity = true
                      xray = false
                      popups = true
              }
          shadow {
              enabled = true
                  range = 15
                  render_power = 5
                  color = rgba(0,0,0,.5)
          }
      }
      animations {
          enabled = true
          bezier = fluid, 0.15, 0.85, 0.25, 1
          bezier = snappy, 0.3, 1, 0.4, 1
          animation = windows, 1, 3, fluid, popin 5%
          animation = windowsOut, 1, 2.5, snappy
          animation = fade, 1, 4, snappy
          animation = workspaces, 1, 1.7, snappy, slide
          animation = specialWorkspace, 1, 4, fluid, slidefadevert -35%
          animation = layers, 1, 2, snappy, popin 70%
      }
      dwindle {
          preserve_split = true
      }
      misc {
          force_default_wallpaper = -1
          disable_hyprland_logo = true
          focus_on_activate = true
      }
      input {
          	kb_layout = us,bg
      	kb_variant = basic,bas_phonetic
      	kb_options = grp:win_space_toggle
              follow_mouse = 2
              sensitivity = 0
              touchpad {
                  natural_scroll = false
              }
      }
      gestures {
              workspace_swipe_distance = 300
              workspace_swipe_cancel_ratio = .05
              workspace_swipe_min_speed_to_force = 0
      }
      device {
          name = epic-mouse-v1
          sensitivity = 0
      }
      $mainMod = SUPER
      bind = $mainMod, Return, exec, $terminal
      bind = CTRL ALT, T, exec, $terminal
      bind = $mainMod SHIFT, Return, exec, gnome-terminal
      bind = $mainMod, Q, killactive
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, S, exec, $browser
      bind = $mainMod, V, exec, cliphist list | wofi --dmenu --pre-display-cmd "echo '%s' | cut -f 2" | cliphist decode | wl-copy
      bind = $mainMod, F11, togglefloating
      bind = $mainMod ALT, Space, exec, $menu
      bind = $mainMod, P, pseudo
      bind = $mainMod, J, togglesplit
      bind = $mainMod, F, fullscreen, 1
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
      bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPause, exec, playerctl play-pause
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioPrev, exec, playerctl previous
      bind = ALT, left, movewindow, l
      bind = ALT, right, movewindow, r
      bind = ALT, up, movewindow, u
      bind = ALT, down, movewindow, d
      bind = $mainMod SHIFT ALT , 4, exec, hyprshot -m region -o ~/Screenshots/
      bind = $mainMod, l, exec, hyprlock
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      bind = ALT, TAB, exec, wlogout -b 2
      bind = $mainMod, w, exec, ~/.config/hypr/wallpaper.sh
      bind = ALT, a, exec, ~/.config/waybar/scripts/refresh.sh
      bind = ALT, B, exec, ~/.config/waybar/scripts/select.sh
      bind = $mainMod, M, exit
      bind = $mainMod, Z, exec, pypr toggle term
      bind = $mainMod, G, exec, pypr toggle music
      bind = $mainMod, H, exec, pypr toggle taskbar
      layerrule = blur, waybar
      layerrule = ignorezero, waybar
      layerrule = ignorealpha 0.5, waybar
      layerrule = noanim, selection
    '';
  };

  # Dotfiles for Hyprland configuration
  home.file = {
    ".config/waybar" = {
      source = ../config/waybar;
      recursive = true;
    };
    ".config/asset" = {
      source = ../config/asset;
      recursive = true;
    };

    # Generate hypridle.conf conditionally based on vm flag
    ".config/hypr/hypridle.conf" = {
      text = ''
        source /home/$USER/.cache/wal/colors-hyprland

        general {
            lock_cmd = pidof hyprlock || hyprlock
            ${lib.optionalString (!vm) "ignore_dbus_inhibit = /opt/spotify/spotify"}
        }
        listener {
            timeout = 270
            on-timeout = source /home/eli/.cache/wal/colors.sh && notify-send "System" "You are about to be locked out!" -i $wallpaper
        }

        listener {
            timeout = 600
            on-timeout = loginctl lock-session
            on-resume = sleep 2 && source /home/eli/.cache/wal/colors.sh && notify-send "System" "Unlocked! Hey $USER" -i $wallpaper
        }

        listener {
            timeout = 1200
            on-timeout = hyprctl dispatch dpms off
            on-resume = hyprctl dispatch dpms on
        }
      '';
    };
    ".config/hypr/hyprlock.conf" = {
      source = ../config/hypr/hyprlock.conf;
    };
    ".config/hypr/hyprpaper.conf" = {
      source = ../config/hypr/hyprpaper.conf;
    };
    ".config/wofi" = {
      source = ../config/wofi;
      recursive = true;
    };
  } // lib.optionalAttrs (!vm) {
    ".config/hypr/pyprland.toml" = {
      text = ''
        [pyprland]
        plugins = [
          "scratchpads"
        ]

        [scratchpads.term]
        animation = "fromTop"
        command = "kitty --class kitty-dropterm"
        class = "kitty-dropterm"
        position = "17% 6%"
        size = "65% 60%"
        offset = "200%"

        [scratchpads.music]
        animation = "fromBottom"
        command = "kitty --class kitty-pulsemixer -e pulsemixer"
        class = "kitty-pulsemixer"
        size = "50% 20%"
        offset = "200%"

        [scratchpads.taskbar]
        animation = "fromLeft"
        command = "ghostty -e htop"
        size = "30% 80%"
        offset = "200%"
      '';
    };
  };

  # Wayland environment variable
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
