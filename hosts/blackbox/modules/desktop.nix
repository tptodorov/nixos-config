{
  pkgs,
  ...
}:
{
  # Desktop environment configuration
  services = {
    # Enable the GNOME Desktop Environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Enable COSMIC Desktop Environment
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;

    # Enable Flatpak for COSMIC Store
    flatpak.enable = true;

    # GNOME services for online accounts and keyring
    gnome = {
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };

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
    # Enable Niri window manager
    niri = {
      enable = true;
    };
    # Brave browser is configured via Home Manager
  };

  # System-wide browser support
  environment.systemPackages = with pkgs; [
    # Browser support packages
    libva
    libva-utils
  ];

  # Hardware acceleration support for browsers
  hardware.graphics = {
    enable = true;
  };
}
