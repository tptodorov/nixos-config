{
  pkgs,
  lib,
  standalone ? false,
  laptop ? false,
  ...
}:
{
  # Desktop applications and GUI tools
  home.packages = with pkgs; [
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

    # Messenger applications
    telegram-desktop
    signal-desktop
    viber
    wasistlos
    zoom-us # Video conferencing
    slack # Team communication

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

  ];

  # Set Brave as default browser in standalone mode using activation script
  home.activation = lib.mkIf standalone {
    setBraveAsDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Unset BROWSER temporarily to allow xdg-settings to work on Omarchy
      OLD_BROWSER="$BROWSER"
      unset BROWSER
      $DRY_RUN_CMD ${pkgs.xdg-utils}/bin/xdg-settings set default-web-browser brave-browser.desktop || true
      export BROWSER="$OLD_BROWSER"

      # Also update mimeapps.list directly for browser-related MIME types
      # This forcefully overrides Omarchy's managed mimeapps.list
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

      # Verify the changes were applied
      if grep -q "brave-browser.desktop" "$MIMEAPPS"; then
        echo "✓ Brave set as default browser in mimeapps.list"
      else
        echo "⚠ Warning: Failed to set Brave as default browser"
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
        exec = "brave --app=https://mail.notion.so/";
        icon = "mail";
        categories = [
          "Network"
          "Email"
        ];
        comment = "Notion Mail as a native application";
      };
      notion-calendar = {
        name = "Notion Calendar";
        exec = "brave --app=https://calendar.notion.so/";
        icon = "calendar";
        categories = [
          "Office"
          "Calendar"
        ];
        comment = "Notion Calendar as a native application";
      };
    };

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

          "inode/directory" = [ "yazi.desktop" ];

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

  # Wayland and GNOME environment variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # GNOME/GTK settings for Nautilus
    GTK_USE_PORTAL = "1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  }
  // lib.optionalAttrs laptop {
    # HiDPI scaling for GTK apps on laptop
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1.5";
  };
}
