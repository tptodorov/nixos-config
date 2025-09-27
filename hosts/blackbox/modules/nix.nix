# Nix store and garbage collection configuration
{
  config,
  pkgs,
  lib,
  ...
}:
{
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
  boot.loader.systemd-boot.configurationLimit = 10;

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

  # Home Manager generation cleanup service
  systemd.services.home-manager-gc = {
    description = "Clean up old Home Manager generations";
    serviceConfig = {
      Type = "oneshot";
      User = "todor";
      Group = "users";
    };
    script = ''
      # Keep only the last 5 Home Manager generations
      ${pkgs.nix}/bin/nix-env --delete-generations +5 --profile /home/todor/.local/state/nix/profiles/home-manager
    '';
  };

  systemd.timers.home-manager-gc = {
    description = "Timer for cleaning up old Home Manager generations";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "2h";
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
}
