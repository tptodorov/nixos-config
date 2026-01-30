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
  # NOTE: Application packages are defined in desktop-apps.nix and other topic-based modules

  # MangoWC configuration
  xdg.configFile."mango/config.conf".text = ''

    #monitorrule=name,mfact,nmaster,layout,transform,scale,x,y,width,height,refreshrate
    monitorrule=DP-3,0.55,1,scroller,0,1.5,0,0,3840,2160,60

    # keyboard inputs
    repeat_rate=60
    repeat_delay=300
    numlockon=1
    xkb_rules_layout=us,bg
    xkb_rules_variant=basic,phonetic
    xkb_rules_options=grp:rwin_toggle

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

    # MangoWC configuration for user todor
    # Integrated with DankMaterialShell

    # Environment setup for systemd services

    exec-once=dms ipc call keybinds toggle mangowc
    exec-once=kitty
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once=systemctl --user start mango-session.target

    # Appearance
    border_radius=12
    borderpx=0
    focused_opacity=1.0
    unfocused_opacity=0.8
    gappih=5
    gappiv=5
    gappoh=5
    gappov=5
    shadows=1
    shadow_only_floating=1
    shadows_size=10
    shadows_blur=15

    # Tag rules 

    # Communications
    tagrule=id:1,no_hide:1,layout_name=scroller
    # Development
    tagrule=id:2,no_hide:1,layout_name=tile


    # Apps assignment
    windowrule=tag:1,isnoborder:1,appid:.*Viber.*
    windowrule=tag:1,isnoborder:1,appid:.*wasist.*
    windowrule=tag:1,isnoborder:1,appid:.*mail.*
    windowrule=tag:1,isnoborder:1,appid:.*calendar.*

    windowrule=tag:2,isnoborder:1,appid:.*zed.*
    

    # Layer rules for DMS
    layerrule=noanim:1,layer_name:^dms

    # Window rules - disable borders for GNOME apps
    windowrule=isnoborder:1,appid:^org\.gnome\.

    # Window rules - disable borders for terminal apps
    windowrule=tag:2,isnoborder:1,appid:^org\.wezfurlong\.wezterm$
    windowrule=tag:2,isnoborder:1,appid:^Alacritty$
    windowrule=tag:2,isnoborder:1,appid:^zen$
    windowrule=tag:2,isnoborder:1,appid:^com\.mitchellh\.ghostty$
    windowrule=tag:2,isnoborder:1,appid:^kitty$

    # Window rules - floating for DMS widgets (quickshell)
    windowrule=isfloating:1,appid:^org\.quickshell$

    # Startup applications
    ${lib.optionalString laptop ''
      # Set output scaling for HiDPI laptop display
      exec-once=${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 2.0
      exec-once=sh -c "echo 'Xft.dpi: 192' | ${pkgs.xorg.xrdb}/bin/xrdb -merge"
    ''}

    exec-once=${pkgs.xwayland-satellite}/bin/xwayland-satellite :1
    exec-once=sh -c "$HOME/.config/mango/scripts/ssh-agent-init.sh"
    exec-once=sh -c "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
    exec-once=sh -c "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
    exec-once=${pkgs.brave}/bin/brave
    exec-once=sh -c "dms ipc wallpaper set ~/.config/asset/3.jpg"
    exec-once=${pkgs.spotify}/bin/spotify
    exec-once=${pkgs.viber}/bin/viber
    exec-once=${pkgs.wasistlos}/bin/wasistlos
    exec-once=${pkgs.brave}/bin/brave --app=https://mail.notion.so/
    exec-once=${pkgs.brave}/bin/brave --app=https://calendar.notion.so/

    source=./bind.conf
  '';

  xdg.configFile."mango/bind.conf".text = ''

    # reload config
    bind=SUPER+SHIFT,r,reload_config

    # switch window focus
    bind=SUPER,Tab,focusstack,next
    bind=SUPER+SHIFT,Tab,focusstack,prev
    bind=SUPER,u,focuslast
    bind=SUPER,Left,focusdir,left  
    bind=SUPER,Right,focusdir,right
    bind=SUPER,Up,focusdir,up
    bind=SUPER,Down,focusdir,down

    # swap window
    bind=SUPER+SHIFT,Up,exchange_client,up
    bind=SUPER+SHIFT,Down,exchange_client,down
    bind=SUPER+SHIFT,Left,exchange_client,left
    bind=SUPER+SHIFT,Right,exchange_client,right

    # movewin
    bind=CTRL+SHIFT,Up,movewin,+0,-50
    bind=CTRL+SHIFT,Down,movewin,+0,+50
    bind=CTRL+SHIFT,Left,movewin,-50,+0
    bind=CTRL+SHIFT,Right,movewin,+50,+0


    # resizewin
    bind=CTRL+ALT,Up,resizewin,+0,-50
    bind=CTRL+ALT,Down,resizewin,+0,+50
    bind=CTRL+ALT,Left,resizewin,-50,+0
    bind=CTRL+ALT,Right,resizewin,+50,+0

    # switch window status
    bind=SUPER,g,toggleglobal,
    bind=SUPER,o,toggleoverview,0
    bind=SUPER,backslash,togglefloating,
    #bind=ALT,a,togglemaximizescreen,
    bind=SUPER,F,togglefullscreen,
    bind=SUPER+SHIFT,o,toggleoverlay,
    #bind=SUPER,i,minimized,
    #bind=SUPER+SHIFT,I,restore_minimized
    #bind=ALT,z,toggle_scratchpad

    # scroller layout
    #bind=SUPER+ALT,e,set_proportion,1.0
    #bind=SUPER+ALT,x,switch_proportion_preset,

    # tile layout
    bind=SUPER+ALT+SHIFT,e,incnmaster,1
    bind=SUPER+ALT+SHIFT,t,incnmaster,-1
    bind=SUPER+ALT+SHIFT,s,zoom,

    # switch layout
    #bind=CTRL+SUPER,i,setlayout,tile
    #bind=CTRL+SUPER,l,setlayout,scroller
    bind=SUPER,L,switch_layout

    # tag switch
    bind=SUPER,Left,viewtoleft,0
    #bind=CTRL,Left,viewtoleft_have_client,0
    bind=SUPER,Right,viewtoright,0
    #bind=CTRL,Right,viewtoright_have_client,0
    bind=CTRL+SUPER,Left,tagtoleft,0
    bind=CTRL+SUPER,Right,tagtoright,0

    bind=SUPER+ALT,1,view,1,0  
    bind=SUPER+ALT,2,view,2,0
    bind=SUPER+ALT,3,view,3,0
    bind=SUPER+ALT,4,view,4,0
    bind=SUPER+ALT,5,view,5,0
    bind=SUPER+ALT,6,view,6,0
    bind=SUPER+ALT,7,view,7,0
    bind=SUPER+ALT,8,view,8,0
    bind=SUPER+ALT,9,view,9,0

    bind=Alt,1,tag,1,0
    bind=Alt,2,tag,2,0
    bind=Alt,3,tag,3,0
    bind=Alt,4,tag,4,0
    bind=Alt,5,tag,5,0
    bind=Alt,6,tag,6,0
    bind=Alt,7,tag,7,0
    bind=Alt,8,tag,8,0
    bind=Alt,9,tag,9,0

    bind=ctrl+Super,1,toggletag,1
    bind=ctrl+Super,2,toggletag,2
    bind=ctrl+Super,3,toggletag,3
    bind=ctrl+Super,4,toggletag,4
    bind=ctrl+Super,5,toggletag,5
    bind=ctrl+Super,6,toggletag,6
    bind=ctrl+Super,7,toggletag,7
    bind=ctrl+Super,8,toggletag,8
    bind=ctrl+Super,9,toggletag,9

    bind=Super,1,toggleview,1
    bind=Super,2,toggleview,2
    bind=Super,3,toggleview,3
    bind=Super,4,toggleview,4
    bind=Super,5,toggleview,5
    bind=Super,6,toggleview,6
    bind=Super,7,toggleview,7
    bind=Super,8,toggleview,8
    bind=Super,9,toggleview,9

    # monitor switch
    bind=alt+shift,Left,focusmon,left
    bind=alt+shift,Right,focusmon,right
    bind=alt+shift,Up,focusmon,up
    bind=alt+shift,Down,focusmon,down
    bind=SUPER+Alt,Left,tagmon,left
    bind=SUPER+Alt,Right,tagmon,right
    bind=SUPER+Alt,Up,tagmon,up
    bind=SUPER+Alt,Down,tagmon,down

    # Mouse Button Bindings
    mousebind=SUPER,btn_left,moveresize,curmove
    mousebind=alt,btn_middle,set_proportion,0.5
    mousebind=SUPER,btn_right,moveresize,curresize
    mousebind=SUPER+CTRL,btn_left,minimized
    mousebind=SUPER+CTRL,btn_right,killclient
    mousebind=SUPER+CTRL,btn_middle,togglefullscreen
    mousebind=NONE,btn_middle,togglemaximizescreen,0
    mousebind=NONE,btn_left,toggleoverview,1
    mousebind=NONE,btn_right,killclient,0

    # Axis Bindings
    axisbind=SUPER,UP,viewtoleft_have_client
    axisbind=SUPER,DOWN,viewtoright_have_client
    axisbind=alt,UP,focusdir,left
    axisbind=alt,DOWN,focusdir,right
    axisbind=shift+super,UP,exchange_client,left
    axisbind=shift+super,DOWN,exchange_client,right

    # Gesturebind
    gesturebind=none,left,3,focusdir,left
    gesturebind=none,right,3,focusdir,right
    gesturebind=none,up,3,focusdir,up
    gesturebind=none,down,3,focusdir,down
    gesturebind=none,left,4,viewtoleft_have_client
    gesturebind=none,right,4,viewtoright_have_client
    gesturebind=none,up,4,toggleoverview,1
    gesturebind=none,down,4,toggleoverview,1

    # OUR CUSTOM BINDS
    # Basic keybindings
    bind=SUPER,slash,spawn,dms ipc call keybinds toggle mangowc
    bind=SUPER,Return,spawn,kitty
    bind=SUPER,Q,killclient,
    bind=SUPER,W,spawn,${pkgs.nautilus}/bin/nautilus
    bind=SUPER,S,spawn,${pkgs.brave}/bin/brave
    bind=SUPER,A,spawn,${pkgs.brave}/bin/brave --app=https://mail.notion.so/

    # Screenshots
    bind=NONE,Print,spawn,dms ipc niri screenshot
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
    bind=SUPER,D,spawn,kitty dgop

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

    # SSH agent initialization script (gnome-keyring removed)
    ".config/mango/scripts/ssh-agent-init.sh" = {
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
}
