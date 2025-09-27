{ config, pkgs, lib, ... }:
{
  # Desktop environment configuration
  services = {
    # Enable the GNOME Desktop Environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable Hyprland
  programs = {
    xwayland.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    firefox.enable = true;
  };
}