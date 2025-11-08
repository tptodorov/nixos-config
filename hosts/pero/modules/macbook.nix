# MacBook-specific configuration
# This module contains settings specific to Apple MacBook hardware
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # MacBook keyboard and function keys
  boot.kernelParams = [
    # Make function keys work as function keys by default (not media keys)
    "hid_apple.fnmode=2"
  ];

  # Load Apple-specific kernel modules
  boot.kernelModules = [ "applesmc" ];

  # Facetimehd camera support (for older MacBooks)
  # Note: May require additional setup for 2017 model
  hardware.facetimehd.enable = lib.mkDefault false;

  # Better power management for Apple hardware
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Thunderbolt support
  services.hardware.bolt.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Sensors for MacBook (temperature, fan speed, etc.)
  environment.systemPackages = with pkgs; [
    lm_sensors  # Hardware monitoring
    # macfanctld is not available in nixpkgs
  ];

  # High DPI display settings for Retina display
  # Adjust as needed based on your preferences
  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # X11 DPI settings (for X applications)
  services.xserver.dpi = lib.mkDefault 144;

  # Better touchpad sensitivity for Apple trackpad
  services.libinput.touchpad = {
    accelSpeed = "0.3";
    accelProfile = "adaptive";
  };
}
