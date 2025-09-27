{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Brave browser configuration
  programs.chromium = {
    enable = true;
    package = pkgs.brave;

    # Default browser extensions (installed automatically)
    extensions = [
      # uBlock Origin
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
      # Bitwarden
      { id = "nngceckbapebfimnlniiiahkandclblb"; }
      # Dark Reader
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
    ];

    # Command line arguments for better Wayland support and performance
    commandLineArgs = [
      # Wayland support
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      # GPU acceleration
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      # Performance
      "--max_old_space_size=4096"
      # Security and privacy
      "--disable-background-networking"
      "--disable-background-timer-throttling"
      "--disable-backgrounding-occluded-windows"
      "--disable-breakpad"
      "--disable-client-side-phishing-detection"
      "--disable-default-apps"
      "--disable-dev-shm-usage"
      "--disable-extensions-http-throttling"
      "--disable-hang-monitor"
      "--disable-ipc-flooding-protection"
      "--disable-renderer-backgrounding"
      "--no-default-browser-check"
      "--password-store=basic"
    ];
  };

  # Desktop file for proper application integration
  xdg.desktopEntries.brave-browser = {
    name = "Brave Web Browser";
    genericName = "Web Browser";
    comment = "Browse the World Wide Web with Brave";
    exec = "brave %U";
    icon = "brave-browser";
    startupNotify = true;
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/xml"
      "application/rss+xml"
      "application/rdf+xml"
      "image/gif"
      "image/jpeg"
      "image/png"
      "image/webp"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/ftp"
      "x-scheme-handler/chrome"
      "video/webm"
      "audio/webm"
      "audio/flac"
      "audio/ogg"
      "video/ogg"
      "audio/mpeg"
      "audio/mp4"
      "video/mp4"
      "application/pdf"
    ];
    settings = {
      StartupWMClass = "brave-browser";
    };
  };

  # Set Brave as default browser
  home.sessionVariables = {
    BROWSER = "brave";
  };

  # Create initial setup script for first run
  home.activation.braveSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Create Brave config directory if it doesn't exist
        mkdir -p "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default"

        # Create a simple initial preferences file if it doesn't exist
        if [ ! -f "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default/Preferences" ]; then
          cat > "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default/Preferences" << 'EOF'
    {
      "bookmark_bar": {
        "show_on_all_tabs": true
      },
      "brave": {
        "shields": {
          "ads_blocked": true,
          "trackers_blocked": true,
          "fingerprinting_blocked": true
        }
      },
      "download": {
        "default_directory": "${config.home.homeDirectory}/Downloads"
      },
      "session": {
        "restore_on_startup": 1
      }
    }
    EOF
        fi
  '';
}
