{
  config,
  lib,
  pkgs,
  vm ? false,
  laptop ? false,
  ...
}:
{
  # MangoWC window manager configuration
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
    wlr-randr # Output management for wlroots compositors

    # GNOME dependencies for Nautilus and secrets management
    gnome-themes-extra
    gsettings-desktop-schemas
    glib
    dconf
    gnome-keyring # Keyring daemon
    libsecret # Secret storage library

    swappy # screenshot editor
  ];

  # MangoWC configuration
  xdg.configFile."mango/config.conf".text = ''
    # MangoWC configuration for user todor
    # Integrated with DankMaterialShell

    # Environment setup for systemd services
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once=systemctl --user start mango-session.target

    # Environment variables
    env=QT_QPA_PLATFORM,wayland
    env=ELECTRON_OZONE_PLATFORM_HINT,auto
    env=QT_QPA_PLATFORMTHEME,gtk3
    env=QT_QPA_PLATFORMTHEME_QT6,gtk3
    env=NIXOS_OZONE_WL,1
    env=XDG_CURRENT_DESKTOP,mango
    env=DMS_SCREENSHOT_EDITOR,swappy
    env=XCURSOR_THEME,Bibata-Modern-Classic
    env=XCURSOR_SIZE,24
    env=DISPLAY,:1
    ${lib.optionalString laptop ''
      # HiDPI scaling for laptop (2x scaling)
      env=GDK_SCALE,2
      env=GDK_DPI_SCALE,0.5
      env=QT_AUTO_SCREEN_SCALE_FACTOR,2
      env=QT_SCALE_FACTOR,2
      env=QT_WAYLAND_FORCE_DPI,192
    ''}

    # Appearance
    border_radius=12
    borderpx=0
    focused_opacity=1.0
    unfocused_opacity=0.9
    gappih=5
    gappiv=5
    gappoh=5
    gappov=5
    shadows=1
    shadow_only_floating=1
    shadows_size=10
    shadows_blur=15

    # Layer rules for DMS
    layerrule=noanim:1,layer_name:^dms

    # Window rules - disable borders for GNOME apps
    windowrule=isnoborder:1,appid:^org\.gnome\.

    # Window rules - disable borders for terminal apps
    windowrule=isnoborder:1,appid:^org\.wezfurlong\.wezterm$
    windowrule=isnoborder:1,appid:^Alacritty$
    windowrule=isnoborder:1,appid:^zen$
    windowrule=isnoborder:1,appid:^com\.mitchellh\.ghostty$
    windowrule=isnoborder:1,appid:^kitty$

    # Window rules - floating for DMS widgets (quickshell)
    windowrule=isfloating:1,appid:^org\.quickshell$

    # Startup applications
    ${lib.optionalString laptop ''
      # Set output scaling for HiDPI laptop display
      exec-once=${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 2.0
      exec-once=sh -c "echo 'Xft.dpi: 192' | ${pkgs.xorg.xrdb}/bin/xrdb -merge"
    ''}
    exec-once=${pkgs.xwayland-satellite}/bin/xwayland-satellite :1
    exec-once=sh -c "dms ipc wallpaper set ~/.config/asset/3.jpg"
    exec-once=sh -c "$HOME/.config/mango/scripts/keyring-init.sh"
    exec-once=sh -c "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
    exec-once=sh -c "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
    exec-once=${pkgs.ghostty}/bin/ghostty
    exec-once=${pkgs.brave}/bin/brave
    exec-once=${pkgs.spotify}/bin/spotify
    exec-once=${pkgs.viber}/bin/viber
    exec-once=${pkgs.wasistlos}/bin/wasistlos
    exec-once=${pkgs.brave}/bin/brave --app=https://mail.notion.so/
    exec-once=${pkgs.brave}/bin/brave --app=https://calendar.notion.so/

    source=./bind.conf
  '';

  xdg.configFile."mango/bind.conf".text = ''

    # Basic keybindings
    bind=SUPER,/,spawn,dms ipc call keybinds toggle mangowc
    bind=SUPER,Return,spawn,${pkgs.ghostty}/bin/ghostty
    bind=SUPER,T,spawn,${pkgs.ghostty}/bin/ghostty
    bind=SUPER,Q,killclient,
    bind=SUPER,E,spawn,${pkgs.nautilus}/bin/nautilus
    bind=SUPER,S,spawn,${pkgs.brave}/bin/brave
    bind=SUPER,A,spawn,${pkgs.geary}/bin/geary

    bind=SUPER,R+SHIFT,reload_config,

    # Window management (vim-style)
    bind=SUPER,H,focusleft,
    bind=SUPER,L,focusright,
    bind=SUPER,K,focusup,
    bind=SUPER,J,focusdown,

    # Window management (arrow keys)
    bind=SUPER,Left,focusleft,
    bind=SUPER,Right,focusright,
    bind=SUPER,Up,focusup,
    bind=SUPER,Down,focusdown,

    # Move windows (vim-style)
    bind=SUPER+SHIFT,H,moveleft,
    bind=SUPER+SHIFT,L,moveright,
    bind=SUPER+SHIFT,K,moveup,
    bind=SUPER+SHIFT,J,movedown,

    # Move windows (arrow keys)
    bind=SUPER+SHIFT,Left,moveleft,
    bind=SUPER+SHIFT,Right,moveright,
    bind=SUPER+SHIFT,Up,moveup,
    bind=SUPER+SHIFT,Down,movedown,

    # Fullscreen
    bind=SUPER,F,fullscreen,

    # Floating windows
    bind=SUPER+SHIFT,F10,togglefloating,

    # Screenshots
    bind=,Print,spawn,dms ipc niri screenshot
    bind=SUPER,Print,spawn,dms ipc niri screenshotScreen
    bind=ALT,Print,spawn,dms ipc niri screenshotWindow

    # Power management
    bind=SUPER+SHIFT,P,spawn,${pkgs.systemd}/bin/systemctl suspend

    # Exit MangoWC
    bind=SUPER+SHIFT,E,quit,

    # DMS Integration
    # Application Launcher
    bind=SUPER,space,spawn,dms ipc call spotlight toggle

    # Clipboard Manager
    bind=SUPER,v,spawn,dms ipc call clipboard toggle

    # Task Manager
    bind=SUPER,m,spawn,dms ipc call processlist focusOrToggle
    bind=CTRL+ALT,Delete,spawn,dms ipc call processlist focusOrToggle

    # Settings
    bind=SUPER,comma,spawn,dms ipc call settings focusOrToggle

    # Notification Center
    bind=SUPER,n,spawn,dms ipc call notifications toggle

    # Browse Wallpapers
    bind=SUPER,y,spawn,dms ipc call dankdash wallpaper

    # Notepad
    bind=SUPER+SHIFT,n,spawn,dms ipc call notepad toggle

    # Lock Screen
    bind=SUPER+ALT,l,spawn,dms ipc call lock lock

    # Audio controls
    bind=NONE,XF86AudioRaiseVolume,spawn,dms ipc call audio increment 3
    bind=NONE,XF86AudioLowerVolume,spawn,dms ipc call audio decrement 3
    bind=NONE,XF86AudioMute,spawn,dms ipc call audio mute
    bind=NONE,XF86AudioMicMute,spawn,dms ipc call audio micmute

    # Brightness controls
    bind=NONE,XF86MonBrightnessUp,spawn,dms ipc call brightness increment 5
    bind=NONE,XF86MonBrightnessDown,spawn,dms ipc call brightness decrement 5
  '';

  # MangoWC-specific configuration files and scripts
  home.file = {
    # Electron flags for proper HiDPI scaling on Wayland
    ".config/electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform,WaylandWindowDecorations
      --ozone-platform=wayland
      --enable-wayland-ime
      --dark
      ${lib.optionalString laptop "--force-device-scale-factor=1.0"}
    '';

    # Gnome keyring initialization script
    ".config/mango/scripts/keyring-init.sh" = {
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

    # Asset folder for desktop access
    ".config/asset".source = ../config/asset;

    # MangoWC session target for systemd
    ".config/systemd/user/mango-session.target".text = ''
      [Unit]
      Description=MangoWC Session Target
      Requires=graphical-session.target
      After=graphical-session.target
    '';
  };

  # Bind DMS to mango-session.target
  systemd.user.services.dms-mango-binding = {
    Unit = {
      Description = "Bind DMS to mango-session.target";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user add-wants mango-session.target dms.service";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Wayland and GNOME environment variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # GNOME/GTK settings for Nautilus
    GTK_USE_PORTAL = "1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  }
  // lib.optionalAttrs laptop {
    # HiDPI scaling for GTK apps on laptop (2x scaling)
    GDK_SCALE = lib.mkForce "1";
    GDK_DPI_SCALE = lib.mkForce "1";
  };

  # Enable dconf for GNOME apps
  dconf.enable = true;
}
