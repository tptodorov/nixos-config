{
  config,
  lib,
  pkgs,
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

      # GPU acceleration and performance
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-hardware-overlays"
      "--max_old_space_size=4096"

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
      "--password-store=gnome-libsecret"

      # Better user experience
      "--no-default-browser-check"
      "--disable-features=TranslateUI"
      "--enable-smooth-scrolling"

      # Audio/Video codec support
      "--enable-features=VaapiVideoDecoder"
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

  # Create Brave configuration directory structure and initial setup
  home.file = {
    # Create Local State file for better profile management
    ".config/BraveSoftware/Brave-Browser/Local State".text = builtins.toJSON {
      profile = {
        info_cache = {
          Default = {
            active_time = 1640995200.0;
            avatar_icon = "chrome://theme/IDR_PROFILE_AVATAR_0";
            background_apps = false;
            gaia_id = "";
            gaia_name = "";
            gaia_picture_file_name = "";
            hosted_domain = "";
            is_consented_primary_account = false;
            is_ephemeral = false;
            is_using_default_avatar = true;
            is_using_default_name = true;
            last_downloaded_gaia_picture_url_with_size = "";
            local_auth_credentials = "";
            managed_user_id = "";
            name = "Person 1";
            shortcut_name = "Person 1";
            user_name = "todor@peychev.com";
          };
        };
        last_used = "Default";
        last_active_profiles = [ "Default" ];
      };
    };

    # Create initial Preferences file optimized for sync
    ".config/BraveSoftware/Brave-Browser/Default/Preferences".text = builtins.toJSON {
      # Account and sync preferences
      account_info = [
        {
          account_id = "todor@peychev.com";
          email = "todor@peychev.com";
          full_name = "Todor Peychev";
        }
      ];

      # Sync configuration - enable all sync features
      sync_prefs = {
        sync_everything = true;
        sync_apps = true;
        sync_autofill = true;
        sync_bookmarks = true;
        sync_extensions = true;
        sync_history = true;
        sync_passwords = true;
        sync_preferences = true;
        sync_reading_list = true;
        sync_tabs = true;
        sync_themes = true;
        sync_typed_urls = true;
      };

      # Sign-in configuration
      signin = {
        allowed = true;
        allowed_on_next_startup = true;
      };

      # Privacy and security settings
      privacy = {
        # WebRTC IP handling
        webrtc = {
          ip_handling_policy = "disable_non_proxied_udp";
        };
        # DNS-over-HTTPS
        dns_over_https = {
          mode = "secure";
          templates = "https://cloudflare-dns.com/dns-query";
        };
      };

      # Brave-specific features
      brave = {
        # Brave Rewards
        rewards = {
          enabled = true;
        };
        # Brave Shields (privacy protection)
        shields = {
          ads_blocked = true;
          trackers_blocked = true;
          javascript_blocked = false;
          fingerprinting_blocked = true;
          cookies_blocked = false;
        };
        # IPFS support
        ipfs = {
          enabled = true;
          auto_redirect_to_configured_gateway = false;
        };
        # Crypto wallet
        wallet = {
          enabled = true;
        };
        # Search engine
        default_search_provider = {
          enabled = true;
          name = "Brave Search";
          keyword = "brave.com";
          search_url = "https://search.brave.com/search?q={searchTerms}";
          suggest_url = "https://search.brave.com/api/suggest?q={searchTerms}";
        };
      };

      # General browser settings
      homepage = "https://search.brave.com";
      homepage_is_newtabpage = false;

      # Session restore
      session = {
        restore_on_startup = 1; # Continue where you left off
      };

      # Bookmarks bar
      bookmark_bar = {
        show_on_all_tabs = true;
      };

      # Download preferences
      download = {
        default_directory = "${config.home.homeDirectory}/Downloads";
        prompt_for_download = false;
        directory_upgrade = true;
      };

      # Tab preferences
      tabs = {
        use_vertical_tabs = false;
      };

      # Password manager integration
      password_manager = {
        enabled = true;
        auto_signin_enabled = true;
      };

      # Autofill settings
      autofill = {
        enabled = true;
        credit_card_enabled = true;
        profile_enabled = true;
      };

      # Performance settings
      background_mode = {
        enabled = false;
      };
    };
  };

  # Activation script to set proper permissions and prepare for first run
  home.activation.braveSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Ensure Brave config directories exist with correct permissions
    mkdir -p "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default"
    mkdir -p "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default/Extensions"

    # Set proper permissions for config files
    chmod 755 "${config.home.homeDirectory}/.config/BraveSoftware"
    chmod 755 "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser"
    chmod 755 "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default"

    if [ -f "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default/Preferences" ]; then
      chmod 644 "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default/Preferences"
    fi

    if [ -f "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Local State" ]; then
      chmod 644 "${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Local State"
    fi

    echo "Brave browser configured with sync support for todor@peychev.com"
    echo "To complete setup:"
    echo "1. Open Brave browser"
    echo "2. Go to Settings > Sync"
    echo "3. Sign in with your Google/Brave account (todor@peychev.com)"
    echo "4. Enable sync for the data types you want to synchronize"
  '';

  # Shell aliases for convenient browser management
  programs.zsh.shellAliases = {
    brave = "brave --profile-directory=Default";
    brave-private = "brave --incognito";
    brave-profile = "brave --profile-directory=";
  };
}
