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
  voxtypeOnnx = voxtypePkgs.onnx or null;
  voxtypeParakeetModel = "parakeet-tdt-0.6b-v3";
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
    if voxtypeOnnx != null then
      pkgs.symlinkJoin {
        name = "voxtype-onnx-wrapped";
        paths = [ voxtypeOnnx ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/voxtype \
            --prefix PATH : ${voxtypeRuntimePath}
        '';
      }
    else
      llmAgentsPkgs.voxtype;
  defaultApps = import ../default-apps.nix { inherit pkgs; };
  isX86Linux = pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64;
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
      wasistlos

      # Notifications
      libnotify # notify-send command

      # Productivity applications
      obsidian
      libreoffice-fresh # LibreOffice suite (Writer, Calc, Impress, Draw, etc.)
      geary # Email client

      # IDEs and dev/design tools
      jetbrains.goland # Go IDE
      vscode
      figma-linux # Unofficial Figma desktop client
      postman # API client
      remmina # Remote desktop client (RDP/VNC/SSH)

      # Scanning applications (for Epson XP-630)
      simple-scan # GNOME's simple scanner application
      xsane # Advanced scanner application

      # PDF editing and manipulation
      pdfarranger # Merge, split, rotate, and rearrange PDF pages
      xournalpp # Annotate and markup PDFs, handwriting support
      evince # GNOME PDF viewer with basic annotation
    ]
    ++ lib.optionals isX86Linux [
      viber
      zoom-us # Video conferencing
      slack # Team communication
      spotify
      discord
      dropbox
    ];

  # Make Brave the session default browser for desktop environments like GNOME.
  home.activation = {
    setBraveAsDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      OLD_BROWSER="''${BROWSER-}"
      unset BROWSER
      $DRY_RUN_CMD ${pkgs.xdg-utils}/bin/xdg-settings set default-web-browser ${defaultApps.browserDesktop} || true
      if [ -n "$OLD_BROWSER" ]; then
        export BROWSER="$OLD_BROWSER"
      fi

      ${lib.optionalString standalone ''
        # Also update mimeapps.list directly for browser-related MIME types.
        # This forcefully overrides Omarchy's managed mimeapps.list.
        MIMEAPPS="$HOME/.config/mimeapps.list"
        if [ -f "$MIMEAPPS" ]; then
          $DRY_RUN_CMD sed -i \
            -e 's|^text/html=.*|text/html=${defaultApps.browserDesktop}|' \
            -e 's|^x-scheme-handler/http=.*|x-scheme-handler/http=${defaultApps.browserDesktop}|' \
            -e 's|^x-scheme-handler/https=.*|x-scheme-handler/https=${defaultApps.browserDesktop}|' \
            -e 's|^x-scheme-handler/about=.*|x-scheme-handler/about=${defaultApps.browserDesktop}|' \
            -e 's|^x-scheme-handler/unknown=.*|x-scheme-handler/unknown=${defaultApps.browserDesktop}|' \
            -e 's|^x-scheme-handler/ftp=.*|x-scheme-handler/ftp=${defaultApps.browserDesktop}|' \
            "$MIMEAPPS"
        fi

        if grep -q "${defaultApps.browserDesktop}" "$MIMEAPPS"; then
          echo "✓ ${defaultApps.browserDesktop} set as default browser in mimeapps.list"
        else
          echo "⚠ Warning: Failed to set Brave as default browser"
        fi
      ''}
    '';

    configureVoxtypeModel = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CONFIG="$HOME/.config/voxtype/config.toml"
      MODEL="${voxtypeParakeetModel}"

      if [ ! -f "$CONFIG" ]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$CONFIG")"
        $DRY_RUN_CMD printf 'engine = "parakeet"\n\n[parakeet]\nmodel = "%s"\nmodel_type = "tdt"\n' "$MODEL" > "$CONFIG"
      else
        if grep -q '^engine = ' "$CONFIG"; then
          $DRY_RUN_CMD sed -i 's|^engine = .*|engine = "parakeet"|' "$CONFIG"
        else
          $DRY_RUN_CMD sed -i '1iengine = "parakeet"' "$CONFIG"
        fi

        if grep -q '^\[parakeet\]' "$CONFIG"; then
          if sed -n '/^\[parakeet\]/,/^\[/{ p; }' "$CONFIG" | grep -q '^model = '; then
            $DRY_RUN_CMD sed -i "/^\[parakeet\]/,/^\[/{ s|^model = .*|model = \"$MODEL\"|; }" "$CONFIG"
          else
            $DRY_RUN_CMD sed -i '/^\[parakeet\]/amodel = "'"$MODEL"'"' "$CONFIG"
          fi
          if sed -n '/^\[parakeet\]/,/^\[/{ p; }' "$CONFIG" | grep -q '^model_type = '; then
            $DRY_RUN_CMD sed -i '/^\[parakeet\]/,/^\[/{ s|^model_type = .*|model_type = "tdt"|; }' "$CONFIG"
          else
            $DRY_RUN_CMD sed -i '/^\[parakeet\]/amodel_type = "tdt"' "$CONFIG"
          fi
        else
          $DRY_RUN_CMD printf '\n[parakeet]\nmodel = "%s"\nmodel_type = "tdt"\n' "$MODEL" >> "$CONFIG"
        fi
      fi
    '';

    disableBrokenVoxtypeOsd = lib.hm.dag.entryAfter [ "configureVoxtypeModel" ] ''
      CONFIG="$HOME/.config/voxtype/config.toml"
      if [ -f "$CONFIG" ] && ! grep -q '^\[osd\]' "$CONFIG"; then
        $DRY_RUN_CMD printf '\n[osd]\nenabled = false\n' >> "$CONFIG"
      fi
    '';

    disableVoxtypeNotifications = lib.hm.dag.entryAfter [ "disableBrokenVoxtypeOsd" ] ''
      CONFIG="$HOME/.config/voxtype/config.toml"
      if [ -f "$CONFIG" ]; then
        if ! grep -q '^\[output\.notification\]' "$CONFIG"; then
          $DRY_RUN_CMD printf '\n[output.notification]\non_recording_start = false\non_recording_stop = false\non_transcription = false\n' >> "$CONFIG"
        else
          for key in on_recording_start on_recording_stop on_transcription; do
            if grep -q "^$key = " "$CONFIG"; then
              $DRY_RUN_CMD sed -i "s|^$key = .*|$key = false|" "$CONFIG"
            else
              $DRY_RUN_CMD sed -i "/^\[output\.notification\]/a$key = false" "$CONFIG"
            fi
          done
        fi
      fi
    '';

    linkYdotoolSocket = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${XDG_RUNTIME_DIR:-}" ] && [ -S /run/ydotoold/socket ]; then
        $DRY_RUN_CMD ln -sfn /run/ydotoold/socket "$XDG_RUNTIME_DIR/.ydotool_socket"
      fi
    '';
  };

  # Automount removable drives (USB sticks, SD cards) on insertion, with a
  # tray icon for unmount/eject. desktop.nix already turns on the system-side
  # services.udisks2 backend; this is the missing user-space piece that
  # actually calls it.
  services.udiskie = {
    enable = true;
    tray = "auto";
    notify = true;
  };

  # XDG configuration
  xdg = {
    enable = true;

    # Custom desktop entries
    desktopEntries = {
      notion-mail = {
        name = "Notion Mail";
        exec = "${defaultApps.browser} --user-data-dir=${config.home.homeDirectory}/.config/brave-apps/notion-mail --app=https://mail.notion.so/";
        icon = "mail";
        categories = [
          "Network"
          "Email"
        ];
        comment = "Notion Mail as a native application";
      };
      notion-calendar = {
        name = "Notion Calendar";
        exec = "${defaultApps.browser} --user-data-dir=${config.home.homeDirectory}/.config/brave-apps/notion-calendar --app=https://calendar.notion.so/";
        icon = "calendar";
        categories = [
          "Office"
          "Calendar"
        ];
        comment = "Notion Calendar as a native application";
      };
    };

    # Voxtype daemon configuration.
    # Managed here so the schema stays valid across upgrades: the root Config
    # struct requires [hotkey], [audio] and output.mode, and voxtype refuses to
    # start if any are missing.
    configFile."voxtype/config.toml".text = ''
      engine = "parakeet"

      [hotkey]
      # Recording is driven by compositor/GNOME keybindings via
      # `voxtype record toggle`, not by voxtype's own evdev grab.
      enabled = false
      mode = "toggle"

      [audio]
      device = "default"
      sample_rate = 16000
      max_duration_secs = 60

      [parakeet]
      model = "${voxtypeParakeetModel}"
      model_type = "tdt"

      # Reject recordings with no detected speech before they reach the model.
      # Without this, near-silent captures make Parakeet hallucinate -- it
      # emitted Portuguese ("Desculpa, ne?") from an English-only model on a
      # silent 2s clip. Energy backend needs no extra model download.
      [vad]
      enabled = true
      backend = "energy"

      [osd]
      enabled = false

      [output]
      mode = "type"
      fallback_to_clipboard = true

      [output.notification]
      on_recording_start = false
      on_recording_stop = false
      on_transcription = false
    '';

    configFile."autostart/voxtype.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Voxtype
      Comment=Voice typing daemon
      Exec=env YDOTOOL_SOCKET=/run/ydotoold/socket ${voxtypePackage}/bin/voxtype --no-hotkey --driver=ydotool,wtype daemon
      OnlyShowIn=GNOME;Umbriel;
      X-GNOME-Autostart-enabled=true
      X-GNOME-Autostart-Delay=2
      NoDisplay=true
    '';

    # MIME type associations
    mimeApps = {
      enable = !standalone;
      defaultApplications =
        let
          browser = [ defaultApps.browserDesktop ];
          editor = defaultApps.editorDesktops;
          markdown = [ defaultApps.notesDesktop ] ++ editor;
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

          "inode/directory" = [ defaultApps.filesDesktop ];

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
    exec = defaultApps.terminalName;
    exec-arg = "";
  };
  dconf.settings."org/gnome/desktop/default-applications/file-manager" = {
    exec = defaultApps.filesName;
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
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal-alt/"
    ];
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype" = {
    name = "Voxtype Dictate";
    command = "${voxtypePackage}/bin/voxtype record toggle";
    binding = "<Super>d";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus" = {
    name = "File Manager";
    command = defaultApps.files;
    binding = "<Super>e";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
    name = "Terminal";
    command = defaultApps.terminal;
    binding = "<Super>t";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal-alt" = {
    name = "Terminal";
    command = defaultApps.terminal;
    binding = "<Alt>t";
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

  # Set internal-microphone capture gain.
  #
  # PipeWire owns this card's ALSA controls and maps its single source volume
  # onto the "Capture" (0..+30 dB) and "Internal Mic Boost" (0..+30 dB) chain,
  # so amixer writes here get overwritten -- the pulse volume is the only
  # effective knob.
  #
  # 40% measured against normal speech at desk distance: peak -11.0 dBFS,
  # noise floor -28.1 dB, 0.00% clipping. 50%+ pushes peaks to -0.4 dBFS and
  # starts clipping at 60%; 30% works but leaves only ~5 dB of speech-over-floor
  # spread. Transcription was accurate at all four levels, so 40% is chosen for
  # headroom rather than intelligibility. Raise if you move further from the box.
  systemd.user.services.mic-gain = lib.mkIf (!standalone) {
    Unit = {
      Description = "Set internal microphone capture gain to a non-clipping level";
      After = [ "pipewire.service" ];
      Wants = [ "pipewire.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "set-mic-gain" ''
        src=alsa_input.pci-0000_c5_00.6.analog-stereo
        ${pkgs.pulseaudio}/bin/pactl list short sources | grep -q "$src" || exit 0
        ${pkgs.pulseaudio}/bin/pactl set-source-volume "$src" 40%
      ''}";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
