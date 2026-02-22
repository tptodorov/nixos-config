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
      enable = false; # Disabled: niri/sway spawn DMS via their own startup commands.
      # This prevents DMS from auto-starting in GNOME sessions.
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

      # Power & Sleep - AC (seconds, 0 = Never)
      acLockTimeout = 600; # Lock after 10 min
      acMonitorTimeout = 300; # Turn off monitors after 5 min
      acSuspendTimeout = 1800; # Suspend after 30 min
      acSuspendBehavior = 0; # 0=Suspend, 1=Hibernate, 2=Suspend then Hibernate
      acProfileName = ""; # Don't change power profile

      # Power & Sleep - Battery (seconds, 0 = Never)
      batteryLockTimeout = 300; # Lock after 5 min
      batteryMonitorTimeout = 180; # Turn off monitors after 3 min
      batterySuspendTimeout = 600; # Suspend after 10 min
      batterySuspendBehavior = 0;
      batteryProfileName = "0"; # Power Saver on battery

      # Fade & grace period before lock/dpms
      fadeToLockEnabled = true;
      fadeToLockGracePeriod = 5;
      fadeToDpmsEnabled = true;
      fadeToDpmsGracePeriod = 5;

      # Lock behavior
      lockBeforeSuspend = true;
      loginctlLockIntegration = true;
    };
  };

  # Fix PATH for systemd service to find quickshell (qs)
  systemd.user.services.dms.Service.Environment = [
    "PATH=${lib.makeBinPath [ inputs.dms.packages.${pkgs.system}.quickshell ]}:/run/current-system/sw/bin"
  ];

  # Lock screen before suspend (lid close, power button, etc.)
  # logind triggers suspend directly, bypassing DMS, so we hook into
  # sleep.target to tell DMS to lock before the system actually sleeps.
  systemd.user.services.dms-lock-before-sleep = {
    Unit = {
      Description = "Lock screen via DMS before suspend";
      Before = [ "sleep.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'dms ipc call lock lock'";
      Environment = "PATH=/run/current-system/sw/bin";
    };
    Install = {
      WantedBy = [ "sleep.target" ];
    };
  };
}
