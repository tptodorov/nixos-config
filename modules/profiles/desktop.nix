# Desktop workstation configuration profile
# This profile provides full desktop environment setup with multiple window managers
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Desktop environment configuration
  services = {
    # Enable the GNOME Desktop Environment
    displayManager.gdm.enable = lib.mkDefault true;
    desktopManager.gnome.enable = lib.mkDefault true;

    # Enable COSMIC Desktop Environment
    desktopManager.cosmic.enable = lib.mkDefault true;
    displayManager.cosmic-greeter.enable = lib.mkDefault true;

    # Enable Flatpak for COSMIC Store
    flatpak.enable = lib.mkDefault true;

    # GNOME services for online accounts and keyring
    gnome = {
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };

  # Enable Hyprland and Niri window managers
  programs = {
    xwayland.enable = true;
    hyprland = {
      enable = lib.mkDefault true;
      xwayland.enable = true;
    };
    niri = {
      enable = lib.mkDefault true;
    };
  };

  # System-wide desktop support packages
  environment.systemPackages = with pkgs; [
    # Browser support packages
    libva
    libva-utils

    # Rust toolchain (needed for COSMIC and other Rust apps)
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
  ];

  # Hardware acceleration support
  hardware.graphics = {
    enable = true;
  };

  # Audio support with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Disable PulseAudio (using PipeWire instead)
  hardware.pulseaudio.enable = false;

  # Add fenix overlay for Rust toolchain
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];
}
