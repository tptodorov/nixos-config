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
    inputs.mango.hmModules.mango

    # Note: DMS niri module removed to avoid conflict with manual niri config
    # We manually manage niri config.kdl and include DMS snippets via include directives
    # Note: DMS doesn't have a separate mango home module
    # MangoWC configuration is handled in mangowc.nix
  ];

  home.packages = [
    inputs.dgop.packages.${pkgs.system}.default
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = false; # Systemd service for auto-start disabled
      restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    };

    enableSystemMonitoring = false; # DMS internal monitoring disabled (use standalone dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)

    settings = {
      theme = "dark";
      dynamicTheming = true;
      useAutoLocation = true;
      compositor = "mango"; # Explicitly set compositor to mango (MangoWC)
      syncModeWithPortal = false; # Don't sync theme with portal (force dark mode)
      nightModeEnabled = false; # Night mode is separate from dark theme
    };

    plugins = {

      #   test = {
      #     enable = true;
      #     src = "https://github.com/Lucyfire/dms-plugins/tree/master/wallpaperDiscovery";
      #   };
    };

  };
}
