{
  pkgs,
  lib,
  vm ? false,
  ...
}:
{
  # Desktop applications and GUI tools
  home.packages =
    with pkgs;
    [
      xdg-utils
      xdg-user-dirs
      # Messenger applications (available on both VM and blackbox)
      telegram-desktop
      signal-desktop
      viber
      wasistlos
    ]
    ++ lib.optionals (!vm || pkgs.stdenv.system != "aarch64-linux") [
      # Discord not available on aarch64-linux
      discord
    ]
    ++ lib.optionals (!vm) [
      # Audio applications (blackbox only, no audio in VM)
      spotify

      # Productivity applications (blackbox only)
      obsidian
      libreoffice-fresh  # LibreOffice suite (Writer, Calc, Impress, Draw, etc.)

      # Email clients
      thunderbird  # Mozilla Thunderbird email client
      mailspring   # Modern email client with unified inbox
    ];

  # XDG configuration
  xdg = {
    enable = true;
    configFile."mimeapps.list".force = true;

    # MIME type associations
    mimeApps = {
      enable = true;
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
          markdown = lib.optionals (!vm) [
            "obsidian.desktop"
          ] ++ editor;
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
          ]
          ++ lib.optionals (!vm) [
            "spotify.desktop"
          ];
          "video/*" = [ "mpv.desktop" ];
          "image/*" = [ "imv-dir.desktop" ];
          "image/gif" = [ "imv-dir.desktop" ];
          "image/jpeg" = [ "imv-dir.desktop" ];
          "image/png" = [ "imv-dir.desktop" ];
          "image/webp" = [ "imv-dir.desktop" ];

          "inode/directory" = [ "yazi.desktop" ];

          # LibreOffice document types (only on non-VM)
        }
        // lib.optionalAttrs (!vm) {
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

          # Email handling
          "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          "message/rfc822" = [ "thunderbird.desktop" ];
        }
        // lib.optionalAttrs (!vm) {
          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop " ];
        };

      associations.removed = { };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
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
}
