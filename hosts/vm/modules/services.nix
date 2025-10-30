{ config, pkgs, lib, ... }:
{
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

    # Printing
    printing.enable = true;
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