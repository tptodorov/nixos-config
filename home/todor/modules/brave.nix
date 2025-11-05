{
  lib,
  pkgs,
  vm ? false,
  ...
}:
{
  # Brave browser configuration with sync support
  programs.chromium = {
    enable = true;
    package = pkgs.brave;

    # Essential extensions for productivity and security
    extensions = [
      # uBlock Origin - Ad blocker
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
      # Bitwarden - Password manager
      { id = "nngceckbapebfimnlniiiahkandclblb"; }
      # Dark Reader - Dark mode for websites
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
      # Privacy Badger - Block trackers
      { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; }
      # ClearURLs - Remove tracking parameters
      { id = "lckanjgmijmafbedllaakclkaicjfmnk"; }
    ];

    # Command line arguments for optimal performance and privacy
    commandLineArgs = [
      # Wayland support for better Linux integration
      "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
      "--ozone-platform=wayland"

      # Security and privacy enhancements
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
      "--disable-background-mode"

      # Sync and profile support
      "--enable-sync"

      # Better user experience
      "--no-default-browser-check"
      "--disable-features=TranslateUI"
      "--enable-smooth-scrolling"
    ] ++ lib.optionals (!vm) [
      # GPU acceleration and performance (only on physical machines)
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-hardware-overlays"
      "--max_old_space_size=4096"
      # Audio/Video codec support
      "--enable-features=VaapiVideoDecoder"
    ] ++ lib.optionals vm [
      # VM-specific flags for better compatibility
      "--disable-gpu"
      "--disable-software-rasterizer"
      "--disable-gpu-compositing"
      "--disable-gpu-rasterization"
      "--disable-gpu-sandbox"
      "--disable-accelerated-2d-canvas"
      "--disable-accelerated-video-decode"
      "--num-raster-threads=1"
      "--ignore-gpu-blocklist"
      "--in-process-gpu"
    ];
  };

  # Desktop file for proper application integration
  xdg.desktopEntries.brave-browser = {
    name = "Brave Web Browser";
    genericName = "Web Browser";
    comment = "Access the Internet with Brave";
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
      StartupNotify = "true";
    };
  };

  # Shell aliases for convenient browser management
  programs.zsh.shellAliases = {
    brave = "brave --profile-directory=Default";
    brave-private = "brave --incognito";
    brave-sync = "brave --new-window brave://settings/syncSetup";
  };

  # Activation script for initial setup hints only
  home.activation.braveSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "🦁 Brave Browser Setup Complete!"
    echo "================================"
    echo ""
    echo "Your Brave browser is now configured with:"
    echo "  • Privacy-focused extensions pre-installed"
    echo "  • Hardware acceleration enabled"
    echo "  • Wayland support enabled"
    echo "  • Sync support ready for todor@peychev.com"
    echo ""
    echo "To complete sync setup:"
    echo "  1. Open Brave: brave"
    echo "  2. Sign in to sync: brave-sync"
    echo "  3. Use your account: todor@peychev.com"
    echo ""
    echo "Useful commands:"
    echo "  • brave          - Open Brave browser"
    echo "  • brave-private  - Open in incognito mode"
    echo "  • brave-sync     - Open sync settings"
  '';
}
