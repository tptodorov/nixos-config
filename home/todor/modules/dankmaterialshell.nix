{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.dms.homeModules.dankMaterialShell.default
    inputs.dms.homeModules.dankMaterialShell.niri

  ];

  programs.dankMaterialShell = {
    enable = true;
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    };

    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableClipboard = true; # Clipboard history manager
    enableVPN = true; # VPN management widget
    enableBrightnessControl = true; # Backlight/brightness controls
    enableColorPicker = true; # Color picker tool
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableSystemSound = true; # System sound effects

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
