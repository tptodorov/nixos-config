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
      enable = true; # Systemd service for auto-start
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

  # Override DMS systemd service to include quickshell in PATH and Wayland display
  systemd.user.services.dms = {
    Unit = {
      # Start DMS automatically with graphical session (niri or any compositor)
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        # Note: WAYLAND_DISPLAY is inherited from the graphical session (e.g., wayland-1 for niri)
        # Don't hardcode it to wayland-0 as different compositors use different socket names
      ];
      # Auto-restart configuration - DMS will restart if it crashes
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "3s";
      StartLimitInterval = lib.mkForce "60s";
      StartLimitBurst = lib.mkForce 5;
    };
  };
}
