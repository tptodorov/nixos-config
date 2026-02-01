# Desktop workstation configuration profile
# This profile provides full desktop environment setup with Niri window manager
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
    # Display Manager configuration
    displayManager.defaultSession = lib.mkDefault "sway";

    # Use greetd with tuigreet for minimal login screen
    # Allows selecting between Niri and Sway from the login menu
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time";
          user = "greeter";
        };
      };
    };
  };

  # Environment variables for display manager
  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Disable gnome-keyring PAM module
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

  # Disable gcr-ssh-agent (conflicts with Home Manager's ssh-agent)
  systemd.user.services.gcr-ssh-agent.enable = lib.mkForce false;
  systemd.user.sockets.gcr-ssh-agent.enable = lib.mkForce false;

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "wlr";
  };

  # Enable Niri and Sway window managers
  programs = {
    xwayland.enable = true;
    niri = {
      enable = lib.mkDefault true;
      package = pkgs.niri-unstable; # Use latest niri build from main branch
    };
    sway = {
      enable = lib.mkDefault true;
      package = pkgs.sway;
    };
  };

  # System-wide desktop support packages
  environment.systemPackages = with pkgs; [
    # Window managers
    sway
    swaybg
    swayidle
    swaylock
    
    # Status bar and utilities
    waybar
    mako
    wofi
    grim
    slurp
    
    # DMS and theming
    swappy
    matugen
    cava

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

  # Configure greetd environments
  environment.etc."greetd/environments".text = ''
    niri-session
    sway
  '';

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
