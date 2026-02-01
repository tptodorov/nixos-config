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
    pkgs.swappy  # Screenshot editor
    pkgs.matugen # Dynamic theming based on wallpaper
    pkgs.cava    # Audio visualizer
  ];

  # DMS configuration
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;  # Enable systemd service for auto-start
      restartIfChanged = true;
    };

    enableSystemMonitoring = false;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;

    settings = {
      theme = "dark";
      dynamicTheming = true;
      useAutoLocation = true;
      syncModeWithPortal = false;
      nightModeEnabled = false;
    };
  };

  # Sway configuration for DMS integration
  # DMS systemd service is managed by the dms module
  # Configure Sway startup if DMS isn't starting automatically
  wayland.windowManager.sway.config = lib.mkIf config.wayland.windowManager.sway.enable {
    startup = lib.optional (config.programs.dank-material-shell.systemd.enable != true) {
      command = "dms run";
      always = false;
    };
  };
}
