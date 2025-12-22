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
      # Add any other settings here
    };

    niri = {
      enableKeybinds = false;
    };

    plugins = {

      #   test = {
      #     enable = true;
      #     src = "https://github.com/Lucyfire/dms-plugins/tree/master/wallpaperDiscovery";
      #   };
    };

  };
}
