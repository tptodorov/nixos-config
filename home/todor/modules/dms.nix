{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Dank Material Shell (DMS) configuration for Sway
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  home.packages = [
    inputs.dgop.packages.${pkgs.system}.default
    inputs.dms.packages.${pkgs.system}.quickshell # Required for DMS to run
    pkgs.swappy # Screenshot editor
    pkgs.matugen # Dynamic theming based on wallpaper
    pkgs.cava # Audio visualizer
  ];

  # DMS configuration
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true; # Enable systemd service for auto-start
      restartIfChanged = true;
    };

    enableSystemMonitoring = false;
    enableVPN = true;
    enableDynamicTheming = false;
    enableAudioWavelength = true;
    enableCalendarEvents = true;

    settings = {
      theme = "dark";
      dynamicTheming = false;
      useAutoLocation = true;
      syncModeWithPortal = false;
      nightModeEnabled = false;
    };
  };

  # Fix PATH for systemd service to find quickshell (qs)
  systemd.user.services.dms.Service.Environment = [
    "PATH=${lib.makeBinPath [ inputs.dms.packages.${pkgs.system}.quickshell ]}:/run/current-system/sw/bin"
  ];
}
