{ config, lib, pkgs, ... }:
{
  # Desktop applications and GUI tools
  home.packages = with pkgs; [
    firefox
    xdg-utils
    xdg-user-dirs
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
            "google-chrome.desktop"
            "firefox.desktop"
          ];
          editor = [
            "Helix.desktop"
            "code.desktop"
            "code-insiders.desktop"
          ];
        in
        {
          "application/json" = browser;
          "application/pdf" = browser;
          "text/html" = browser;
          "text/xml" = browser;
          "text/plain" = editor;
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
          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop " ];

          # Media types
          "audio/*" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "image/*" = [ "imv-dir.desktop" ];
          "image/gif" = [ "imv-dir.desktop" ];
          "image/jpeg" = [ "imv-dir.desktop" ];
          "image/png" = [ "imv-dir.desktop" ];
          "image/webp" = [ "imv-dir.desktop" ];

          "inode/directory" = [ "yazi.desktop" ];
        };

      associations.removed = {};
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