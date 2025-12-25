{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.mango.hmModules.mango

    # Note: DMS doesn't have a separate mango home module
    # MangoWC configuration is handled in mangowc.nix
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    };

    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    # enableClipboard = true; # Now built-in (deprecated)
    enableVPN = true; # VPN management widget
    # enableBrightnessControl = true; # Now built-in (deprecated)
    # enableColorPicker = true; # Now built-in (deprecated)
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    # enableSystemSound = true; # Now built-in (deprecated)

    default.settings = {
      theme = "dark";
      dynamicTheming = true;
      useAutoLocation = true;
      compositor = "mango"; # Explicitly set compositor to mango (MangoWC)
      syncModeWithPortal = false; # Don't sync theme with portal (force dark mode)
      nightModeEnabled = false; # Night mode is separate from dark theme
    };

    niri = {
      enableKeybinds = false;
    };

    # Note: MangoWC keybinds are configured directly in mangowc.nix
    # DMS will work with MangoWC through the systemd integration

    plugins = {

      #   test = {
      #     enable = true;
      #     src = "https://github.com/Lucyfire/dms-plugins/tree/master/wallpaperDiscovery";
      #   };
    };

  };

  # Override DMS systemd service to include quickshell in PATH and Wayland display
  systemd.user.services.dms = {
    Unit = {
      After = [ "mango-session.target" ];
      Wants = [ "mango-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        "WAYLAND_DISPLAY=wayland-0"
      ];
    };
  };
}
