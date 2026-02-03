{ config, pkgs, lib, ... }:
{
  # Docker - Container runtime
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };

  # System services configuration
  security.rtkit.enable = true;

  services = {
    # Audio services
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Firmware updates
    fwupd.enable = true;

    # Printing - CUPS with Epson XP-630 support
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint        # General printer drivers (includes Epson support)
        epson-escpr       # Epson ESC/P-R driver (official Epson driver)
        epson-escpr2      # Epson ESC/P-R driver v2 (newer models)
      ];
      # Allow browsing and sharing printers on the network
      browsing = true;
      defaultShared = false;
      # Listen on all network interfaces for incoming print jobs
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      # Configure cups-browsed for network printer discovery
      browsedConf = ''
        BrowseRemoteProtocols dnssd cups
        BrowseLocalProtocols dnssd cups
      '';
    };

    # Avahi - for network printer/scanner discovery (mDNS/DNS-SD)
    avahi = {
      enable = true;
      nssmdns4 = true;  # Enable mDNS resolution in NSS
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };

  };

  # SANE - Scanner Access Now Easy (for Epson XP-630 scanner)
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan       # Network scanner support (eSCL/AirPrint scanning)
      epkowa             # Epson Kowa (Image Scan! for Linux) - for older Epson scanners
    ];
    # Network scanning support
    netConf = ''
      # Allow scanning from network scanners
      # Format: scanner-ip-address
      # Example: 192.168.1.100
    '';
  };

  # System settings
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix configuration
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "todor"
    "root"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

