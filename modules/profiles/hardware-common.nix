# Common hardware configuration patterns
# This module provides standardized hardware setup for all hosts
{
  lib,
  pkgs,
  ...
}:
{
  # Enable all firmware
  hardware.enableAllFirmware = lib.mkDefault true;

  # Enable graphics acceleration
  hardware.graphics = {
    enable = lib.mkDefault true;
  };

  # Bluetooth support
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };

  # CPU frequency scaling
  powermanagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # Common hardware packages
  environment.systemPackages = with pkgs; [
    lm_sensors      # Temperature monitoring
    dmidecode       # Hardware info
    usbutils        # USB utilities
    pciutils        # PCI utilities
  ];
}
