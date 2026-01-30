# Desktop workstation configuration profile
# This profile provides full desktop environment setup with multiple window managers
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Mac-style keyboard remapping
    ./keyd-mac.nix
  ];
  # Desktop environment configuration
  services = {
    # GNOME Desktop Environment - DISABLED
    # displayManager.gdm.enable = lib.mkDefault false;
    # desktopManager.gnome.enable = lib.mkDefault false;

    # Enable COSMIC Desktop Environment
    desktopManager.cosmic.enable = lib.mkDefault true;
    displayManager.cosmic-greeter.enable = lib.mkDefault true;

    # Enable Flatpak for COSMIC Store
    flatpak.enable = lib.mkDefault true;

    # GNOME services disabled - not using GNOME desktop
    gnome.gnome-keyring.enable = lib.mkForce false;
  };

  # Disable gnome-keyring PAM module (sets SSH_AUTH_SOCK incorrectly)
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

  # Disable gcr-ssh-agent (conflicts with Home Manager's ssh-agent)
  systemd.user.services.gcr-ssh-agent.enable = lib.mkForce false;
  systemd.user.sockets.gcr-ssh-agent.enable = lib.mkForce false;

  # XDG Portal configuration - use GNOME backend to avoid GTK portal timeouts
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };

  # Enable Hyprland, Niri, and MangoWC window managers
  programs = {
    xwayland.enable = true;
    niri = {
      enable = lib.mkDefault true;
      package = pkgs.niri-unstable; # Use latest niri build from main branch
    };
    mango = {
      enable = lib.mkDefault true; # Enable MangoWC compositor
    };
  };

  # System-wide desktop support packages
  environment.systemPackages = with pkgs; [
    # Browser support packages
    libva
    libva-utils

    # Disk management
    gparted

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
  services.pulseaudio.enable = false;

  # Add fenix overlay for Rust toolchain
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];
}
