# Base system configuration profile
# This profile provides essential configuration for all NixOS hosts
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Bootloader configuration (can be overridden by specific hosts)
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Nix settings
  nix = {
    # Enable flakes and new command line interface
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # Garbage collection configuration
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Automatic store optimization
    optimise = {
      automatic = true;
      dates = [ "03:45" ]; # Run daily at 3:45 AM
    };
  };

  # Boot loader garbage collection - keep only last 10 generations
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;

  # Limit the number of generations to keep
  system.autoUpgrade = {
    enable = false; # We manage updates manually with flakes
  };

  # Clean up old generations weekly
  systemd.services.nix-gc-generations = {
    description = "Clean up old NixOS generations";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      # Keep only the last 10 system generations
      ${pkgs.nix}/bin/nix-env --delete-generations +10 --profile /nix/var/nix/profiles/system

      # Clean up boot entries
      /run/current-system/bin/switch-to-configuration boot
    '';
  };

  systemd.timers.nix-gc-generations = {
    description = "Timer for cleaning up old NixOS generations";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Journal size limits to prevent log buildup
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemKeepFree=1G
    SystemMaxFileSize=50M
    SystemMaxFiles=10
    MaxRetentionSec=1month
  '';

  # Basic networking
  networking.networkmanager.enable = lib.mkDefault true;

  # Enable OpenSSH daemon
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
    };
  };

  # Enable mDNS for hostname resolution (.local)
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tree
    ripgrep
    age
    sops
    efibootmgr
    inputs.home-manager.packages.${pkgs.system}.default
  ];

  # Configure keymap
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = lib.mkDefault "";
  };
}
