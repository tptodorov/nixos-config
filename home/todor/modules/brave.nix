{
  lib,
  pkgs,
  ...
}:
let
  # Gopass Bridge (github:gopasspw/gopassbridge) talks to gopass-jsonapi over
  # Chrome's native messaging protocol, not a shell pipe -- there is no TTY,
  # so GUI pinentry (pinentry-gnome3/pinentry-bemenu, already wired for
  # gopass elsewhere) is what will prompt for the GPG passphrase.
  gopassJsonapiWrapper = pkgs.writeShellApplication {
    name = "gopass-jsonapi-wrapper";
    runtimeInputs = [
      pkgs.gopass-jsonapi
      pkgs.gopass
      pkgs.gnupg
    ];
    text = ''
      exec gopass-jsonapi listen
    '';
  };
in
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
      # Gopass Bridge - Fill logins from the gopass password store
      { id = "kkhfnlkhiapbiehimabddjbimfaijdhk"; }
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
      "--restore-last-session"
      "--no-default-browser-check"
      "--disable-features=TranslateUI"
      "--enable-smooth-scrolling"

      # GPU acceleration and performance
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-hardware-overlays"
      "--max_old_space_size=4096"

      # Audio/Video codec support
      "--enable-features=VaapiVideoDecoder"
    ];
  };

  home.packages = [ gopassJsonapiWrapper ];

  # Native messaging host manifest for Gopass Bridge. Chrome-family browsers
  # only look for this under the browser's OWN config dir, not a shared
  # Chromium location -- Brave's is BraveSoftware/Brave-Browser, not
  # ~/.config/chromium. Host name and allowed_origins come from
  # gopass-jsonapi's own manifest package (com.justwatch.gopass /
  # chrome-extension://kkhfnlkhiapbiehimabddjbimfaijdhk/), reproduced here
  # by hand since `gopass-jsonapi configure` is interactive and would fight
  # a declarative config on every run.
  xdg.configFile."BraveSoftware/Brave-Browser/NativeMessagingHosts/com.justwatch.gopass.json".text =
    builtins.toJSON {
      name = "com.justwatch.gopass";
      description = "Gopass wrapper to search and return passwords";
      path = "${gopassJsonapiWrapper}/bin/gopass-jsonapi-wrapper";
      type = "stdio";
      allowed_origins = [ "chrome-extension://kkhfnlkhiapbiehimabddjbimfaijdhk/" ];
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

  # Activation script to set session restore preference
  home.activation.braveSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    BRAVE_PREFS="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"

    # Only modify if Brave profile exists and Preferences file exists
    if [ -f "$BRAVE_PREFS" ]; then
      echo "Configuring Brave to auto-restore previous session..."

      # Use jq to modify the Preferences file if available, otherwise create a backup
      if command -v ${pkgs.jq}/bin/jq &> /dev/null; then
        # Create backup
        cp "$BRAVE_PREFS" "$BRAVE_PREFS.bak"

        # Set restore_on_startup to 1 (restore last session)
        ${pkgs.jq}/bin/jq '.session.restore_on_startup = 1' "$BRAVE_PREFS.bak" > "$BRAVE_PREFS"

        echo "✓ Brave configured to restore previous session automatically"
      fi
    fi

    echo "🦁 Brave Browser Setup Complete!"
    echo "================================"
    echo ""
    echo "Your Brave browser is now configured with:"
    echo "  • Privacy-focused extensions pre-installed"
    echo "  • Hardware acceleration enabled"
    echo "  • Wayland support enabled"
    echo "  • Auto-restore previous session enabled"
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
