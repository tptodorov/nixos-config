{
  config,
  pkgs,
  lib,
  inputs,
  standalone ? false,
  laptop ? false,
  ...
}:
let
  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  voxtypePkgs = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system} or { };
  voxtypeVulkan = voxtypePkgs.vulkan or null;
  voxtypeUnwrapped = voxtypePkgs.voxtype-vulkan-unwrapped or null;
  voxtypeRuntimePath = lib.makeBinPath [
    pkgs.which
    pkgs.wtype
    pkgs.wl-clipboard
    pkgs.ydotool
    pkgs.xdotool
    pkgs.xclip
    pkgs.libnotify
    pkgs.pciutils
    pkgs.dotool
  ];
  voxtypePackage =
    if voxtypeVulkan != null && voxtypeUnwrapped != null then
      pkgs.symlinkJoin {
        name = "voxtype-vulkan-wrapped";
        paths = [
          (voxtypeUnwrapped.overrideAttrs (_: {
            # v0.7.1's check phase compiles an ONNX example without its optional ort dependency.
            doCheck = false;
          }))
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/voxtype \
            --prefix PATH : ${voxtypeRuntimePath}
        '';
      }
    else
      llmAgentsPkgs.voxtype;
in
{
  # Desktop applications and GUI tools
  home.packages =
    with pkgs;
    [
      xdg-utils
      xdg-user-dirs

      # File managers
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
      wlrctl # Control wlroots compositors
      walker # Application launcher and clipboard manager
      wl-clipboard # Wayland clipboard integration for Voxtype and shell tools
      dotool # Keyboard simulation for GNOME/KDE Wayland
      ydotool # uinput-backed keyboard simulation for GNOME Wayland
      playerctl # Optional MPRIS media pause integration for Voxtype
      alsa-utils # arecord/aplay for Voxtype audio smoke tests

      # Keybinding testing
      xev # X11 event viewer
      wev # Wayland event viewer
      wtype # Wayland keyboard input simulator (for paste)

      # Screenshot tools
      swappy # Screenshot editor

      # GNOME dependencies for Nautilus
      gnome-themes-extra
      gsettings-desktop-schemas
      glib
      dconf
      gtk4-layer-shell # Optional GTK4 OSD runtime for Voxtype

      # Messenger applications
      telegram-desktop
      signal-desktop
      viber
      wasistlos
      zoom-us # Video conferencing
      slack # Team communication

      # Notifications
      libnotify # notify-send command

      # Audio applications
      spotify
      discord

      # Productivity applications
      obsidian
      libreoffice-fresh # LibreOffice suite (Writer, Calc, Impress, Draw, etc.)
      geary # Email client

      # Scanning applications (for Epson XP-630)
      simple-scan # GNOME's simple scanner application
      xsane # Advanced scanner application

      # PDF editing and manipulation
      pdfarranger # Merge, split, rotate, and rearrange PDF pages
      xournalpp # Annotate and markup PDFs, handwriting support
      evince # GNOME PDF viewer with basic annotation
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64) [
      dropbox
    ];

  # Make Brave the session default browser for desktop environments like GNOME.
  home.activation = {
    setBraveAsDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      OLD_BROWSER="''${BROWSER-}"
      unset BROWSER
      $DRY_RUN_CMD ${pkgs.xdg-utils}/bin/xdg-settings set default-web-browser brave-browser.desktop || true
      if [ -n "$OLD_BROWSER" ]; then
        export BROWSER="$OLD_BROWSER"
      fi

      ${lib.optionalString standalone ''
        # Also update mimeapps.list directly for browser-related MIME types.
        # This forcefully overrides Omarchy's managed mimeapps.list.
        MIMEAPPS="$HOME/.config/mimeapps.list"
        if [ -f "$MIMEAPPS" ]; then
          $DRY_RUN_CMD sed -i \
            -e 's|^text/html=.*|text/html=brave-browser.desktop|' \
            -e 's|^x-scheme-handler/http=.*|x-scheme-handler/http=brave-browser.desktop|' \
            -e 's|^x-scheme-handler/https=.*|x-scheme-handler/https=brave-browser.desktop|' \
            -e 's|^x-scheme-handler/about=.*|x-scheme-handler/about=brave-browser.desktop|' \
            -e 's|^x-scheme-handler/unknown=.*|x-scheme-handler/unknown=brave-browser.desktop|' \
            -e 's|^x-scheme-handler/ftp=.*|x-scheme-handler/ftp=brave-browser.desktop|' \
            "$MIMEAPPS"
        fi

        if grep -q "brave-browser.desktop" "$MIMEAPPS"; then
          echo "✓ Brave set as default browser in mimeapps.list"
        else
          echo "⚠ Warning: Failed to set Brave as default browser"
        fi
      ''}
    '';

    disableBrokenVoxtypeOsd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CONFIG="$HOME/.config/voxtype/config.toml"
      if [ -f "$CONFIG" ] && ! grep -q '^\[osd\]' "$CONFIG"; then
        $DRY_RUN_CMD printf '\n[osd]\nenabled = false\n' >> "$CONFIG"
      fi
    '';

    linkYdotoolSocket = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${XDG_RUNTIME_DIR:-}" ] && [ -S /run/ydotoold/socket ]; then
        $DRY_RUN_CMD ln -sfn /run/ydotoold/socket "$XDG_RUNTIME_DIR/.ydotool_socket"
      fi
    '';
  };

  # XDG configuration
  xdg = {
    enable = true;

    # Custom desktop entries
    desktopEntries = {
      notion-mail = {
        name = "Notion Mail";
        exec = "brave --user-data-dir=${config.home.homeDirectory}/.config/brave-apps/notion-mail --app=https://mail.notion.so/";
        icon = "mail";
        categories = [
          "Network"
          "Email"
        ];
        comment = "Notion Mail as a native application";
      };
      notion-calendar = {
        name = "Notion Calendar";
        exec = "brave --user-data-dir=${config.home.homeDirectory}/.config/brave-apps/notion-calendar --app=https://calendar.notion.so/";
        icon = "calendar";
        categories = [
          "Office"
          "Calendar"
        ];
        comment = "Notion Calendar as a native application";
      };
    };

    configFile."autostart/voxtype.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Voxtype
      Comment=Voice typing daemon
      Exec=env YDOTOOL_SOCKET=/run/ydotoold/socket ${voxtypePackage}/bin/voxtype --no-hotkey --driver=ydotool,wtype daemon
      OnlyShowIn=GNOME;
      X-GNOME-Autostart-enabled=true
      X-GNOME-Autostart-Delay=2
      NoDisplay=true
    '';

    # MIME type associations
    mimeApps = {
      enable = !standalone;
      defaultApplications =
        let
          browser = [
            "brave-browser.desktop"
          ];
          editor = [
            "Helix.desktop"
            "code.desktop"
            "code-insiders.desktop"
          ];
          markdown = [ "obsidian.desktop" ] ++ editor;
        in
        {
          "application/json" = browser;
          "application/pdf" = browser;
          "text/html" = browser;
          "text/xml" = browser;
          "text/plain" = editor;
          "text/markdown" = markdown;
          "application/xml" = browser;
          "application/xhtml+xml" = browser;
          "application/xhtml_xml" = browser;
          "application/rdf+xml" = browser;
          "application/rss+xml" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/x-extension-xht" = browser;
          "application/x-extension-xhtml" = browser;
          "application/x-wine-extension-ini" = editor;

          # URL schemes
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/ftp" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/vscode" = [ "code-url-handler.desktop" ];
          "x-scheme-handler/vscode-insiders" = [ "code-insiders-url-handler.desktop" ];
          "x-scheme-handler/zoommtg" = [ "Zoom.desktop" ];

          # Media types
          "audio/*" = [
            "mpv.desktop"
            "spotify.desktop"
          ];
          "video/*" = [ "mpv.desktop" ];
          "image/*" = [ "imv-dir.desktop" ];
          "image/gif" = [ "imv-dir.desktop" ];
          "image/jpeg" = [ "imv-dir.desktop" ];
          "image/png" = [ "imv-dir.desktop" ];
          "image/webp" = [ "imv-dir.desktop" ];

          "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

          # LibreOffice document types
          # Writer documents
          "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.text-template" = [ "writer.desktop" ];
          "application/msword" = [ "writer.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];

          # Calc spreadsheets
          "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.spreadsheet-template" = [ "calc.desktop" ];
          "application/vnd.ms-excel" = [ "calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];

          # Impress presentations
          "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
          "application/vnd.oasis.opendocument.presentation-template" = [ "impress.desktop" ];
          "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];

          # Telegram handler
          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop " ];
        };

      associations.removed = { };
    };

    userDirs = {
      enable = !standalone;
      createDirectories = !standalone;
    };
  };

  # Cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # DPI settings for 4K monitor
  xresources.properties = {
    "Xft.dpi" = 150;
    "*.dpi" = 150;
  };

  # GTK theme
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      package = pkgs.noto-fonts;
      size = 11;
    };
  };

  # Enable dconf for GNOME apps
  dconf.enable = true;
  dconf.settings."org/gnome/desktop/default-applications/terminal" = {
    exec = "kitty";
    exec-arg = "";
  };
  dconf.settings."org/gnome/desktop/default-applications/file-manager" = {
    exec = "nautilus";
    exec-arg = "";
  };
  dconf.settings."org/gnome/desktop/input-sources" = {
    # GNOME/XKB-level Alt↔Super swap. This makes the physical Alt/Option key
    # act as Super without running keyd.
    xkb-options = [ "altwin:swap_alt_win" ];
  };

  # GNOME custom keybindings
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys" = {
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
    ];
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype" = {
    name = "Voxtype Dictate";
    command = "${voxtypePackage}/bin/voxtype record toggle";
    binding = "<Super>d";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus" = {
    name = "File Manager";
    command = "nautilus";
    binding = "<Super>e";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
    name = "Terminal";
    command = "kitty";
    binding = "<Super>t";
  };

  # GNOME window/app switching.
  dconf.settings."org/gnome/desktop/wm/keybindings" = {
    switch-applications = [
      "<Super>Tab"
    ];
    switch-applications-backward = [
      "<Shift><Super>Tab"
    ];

    # Move window to monitor — physical Ctrl+Alt+Super+PageUp/PageDown
    # Left/Right are hardware-ghosted with 3 modifiers on this keyboard
    move-to-monitor-left = [ "<Primary><Super><Alt>Prior" ];
    move-to-monitor-right = [ "<Primary><Super><Alt>Next" ];
  };

  # Wayland environment variables
  # Note: GTK_USE_PORTAL and GSETTINGS_SCHEMA_DIR are not set here —
  # GNOME manages these itself, and niri/sway don't need them globally.
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    YDOTOOL_SOCKET = "/run/ydotoold/socket";
  }
  // lib.optionalAttrs laptop {
    # HiDPI scaling for GTK apps on laptop
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1.5";
  };

  systemd.user.sessionVariables = {
    YDOTOOL_SOCKET = "/run/ydotoold/socket";
  };
}
