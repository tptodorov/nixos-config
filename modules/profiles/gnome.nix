# GNOME Desktop Environment profile
# Import this alongside desktop.nix to use GNOME with GDM as the default session.
# Niri and Sway remain available as alternative sessions at the GDM login screen.
{ pkgs, lib, ... }:
{
  # Enable GNOME desktop environment
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;

  # Use GDM as the display manager (replaces greetd from desktop.nix).
  # mkOverride 60 beats desktop.nix's normal-priority definitions (1000; lower
  # numbers win) but still loses to a host that sets mkForce (50), so a host can
  # opt into a different greeter without this profile having to know about it.
  services.displayManager.gdm.enable = lib.mkOverride 60 true;
  services.displayManager.defaultSession = lib.mkOverride 60 "gnome";

  # Disable greetd (conflicts with GDM)
  services.greetd.enable = lib.mkOverride 60 false;

  # Re-enable GNOME keyring (desktop.nix disables it for tiling WM setups)
  security.pam.services.login.enableGnomeKeyring = lib.mkForce true;

  # Re-enable gcr-ssh-agent (GNOME uses this for SSH key management)
  systemd.user.services.gcr-ssh-agent.enable = lib.mkForce true;
  systemd.user.sockets.gcr-ssh-agent.enable = lib.mkForce true;

  # Add GNOME XDG portal (wlr portal from desktop.nix is kept for niri/sway sessions)
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  xdg.portal.config.gnome.default = "gnome";
  # Route Camera portal to gnome for all sessions (wlr does not support Camera)
  xdg.portal.config.common."org.freedesktop.impl.portal.Camera" = "gnome";

  # GNOME extensions and tools
  environment.systemPackages = with pkgs; [
    # Extension management
    gnome-extensions-cli # CLI tool: gext install/update/enable extensions
    gnome-tweaks # Advanced GNOME settings (fonts, themes, extensions, etc.)
    gnome-extension-manager # GUI app to browse, install, and manage extensions

    # Popular extensions
    gnomeExtensions.appindicator # System tray icons (needed for many apps)
    gnomeExtensions.dash-to-dock # macOS-style dock
    gnomeExtensions.pop-shell # Tiling window management (Pop!_OS style)
    gnomeExtensions.blur-my-shell # Blur effects on shell UI
    gnomeExtensions.clipboard-indicator # Clipboard history manager
    gnomeExtensions.gsconnect # Phone integration (KDE Connect protocol)
    gnomeExtensions.caffeine # Prevent auto-suspend/screen lock
    gnomeExtensions.vitals # System monitoring in top bar
    gnomeExtensions.space-bar # Workspace indicator in top bar
  ];

  # Enable chrome-gnome-shell for browser-based extension installation
  services.gnome.gnome-browser-connector.enable = true;
}
