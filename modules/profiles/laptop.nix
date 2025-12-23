# Laptop configuration profile
# This profile provides laptop-specific optimizations and power management
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Power management with TLP
  services.tlp = {
    enable = true;
    settings = {
      # Battery thresholds (if supported by hardware)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU scaling governor
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU frequency scaling
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Enable audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;

      # Runtime power management for PCI(e) devices
      # Note: "on" means runtime PM is disabled, "auto" means enabled
      # For MacBook Pro 2017, keep devices active to prevent suspend issues
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "on";  # Changed from "auto" to fix MacBook suspend issues

      # Exclude specific devices from runtime PM to prevent suspend issues
      # Particularly important for NVMe and Thunderbolt on MacBook Pro 2017
      RUNTIME_PM_BLACKLIST = "01:00.0";  # Typically NVMe controller

      # WiFi power saving (disabled for MacBook Pro 2017 Broadcom WiFi stability)
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
    };
  };

  # Thermald for Intel CPU thermal management
  services.thermald.enable = lib.mkDefault true;

  # Enable laptop-specific services
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "suspend";
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "30min";
    };
  };

  # Disable power-profiles-daemon (conflicts with TLP)
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = lib.mkDefault true;
      tapping = lib.mkDefault true;
      disableWhileTyping = lib.mkDefault true;
      clickMethod = lib.mkDefault "clickfinger";
      accelSpeed = lib.mkDefault "0.2";
    };
  };

  # Backlight control
  programs.light.enable = true;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi           # Battery status
    powertop       # Power consumption analysis
    brightnessctl  # Backlight control
  ];

  # Intel WiFi 7 BE200 fix for suspend/resume issues
  # Based on: https://bbs.archlinux.org/viewtopic.php?id=293404
  # Disable power management features that cause firmware crashes
  boot.extraModprobeConfig = ''
    # Disable WiFi power save to prevent firmware crashes after suspend
    options iwlwifi power_save=0
    # Disable U-APSD (Unscheduled Automatic Power Save Delivery) for stability
    # Default is 3 (both BSS and P2P), setting to 3 keeps default behavior
    options iwlwifi uapsd_disable=3
  '';

  # Use NixOS power management hooks to unload/reload WiFi module
  # This prevents the "Unable to change power state from D3cold to D0" error
  # that causes WiFi to fail after resume on BE200 devices
  powerManagement = {
    powerDownCommands = ''
      # Unload iwlwifi modules before suspend
      ${pkgs.kmod}/bin/modprobe -r iwlmld 2>/dev/null || true
      ${pkgs.kmod}/bin/modprobe -r iwlwifi 2>/dev/null || true
      ${pkgs.coreutils}/bin/sleep 0.5
    '';
    resumeCommands = ''
      # Reload iwlwifi after resume
      ${pkgs.kmod}/bin/modprobe iwlwifi
      ${pkgs.coreutils}/bin/sleep 1
      # Restart NetworkManager to ensure WiFi reconnects
      ${pkgs.systemd}/bin/systemctl restart NetworkManager
    '';
  };

  # Auto-cpufreq as an alternative to TLP (disabled by default)
  # Uncomment if you prefer auto-cpufreq over TLP
  # services.auto-cpufreq.enable = false;
}
