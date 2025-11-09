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

    # Fix suspend/resume issues on MacBook Pro 2017
    # Force proper ACPI behavior and enable S3 sleep state
    "acpi=strict"
    "mem_sleep_default=deep"

    # Additional ACPI tweaks for better compatibility
    "acpi_osi=Linux"
    "acpi_backlight=video"
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

  # Fix suspend/resume issues specific to MacBook Pro 2017
  # Disable problematic ACPI wakeup sources that cause immediate wakeup
  systemd.services.disable-acpi-wakeup = {
    description = "Disable problematic ACPI wakeup sources (XHC1)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    script = ''
      # Disable XHC1 (USB 3.0) wakeup - causes immediate resume
      if ${pkgs.gnugrep}/bin/grep -q "^XHC1.*enabled" /proc/acpi/wakeup 2>/dev/null; then
        echo XHC1 > /proc/acpi/wakeup
        echo "Disabled XHC1 wakeup source"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Disable D3 Cold power state for NVMe and Thunderbolt to fix slow resume
  systemd.services.disable-d3cold = {
    description = "Disable D3 Cold power state for NVMe and Thunderbolt devices";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    script = ''
      # Find and disable d3cold for all PCI devices
      # This fixes "Unable to change power state" errors on resume
      for device in /sys/bus/pci/devices/*/d3cold_allowed; do
        if [ -f "$device" ]; then
          echo 0 > "$device" || true
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Unload WiFi driver before suspend to prevent suspend failure
  # The brcmfmac driver on MacBook Pro 2017 fails to suspend (error -5)
  # so we unload it before suspend and reload it after resume
  systemd.services.wifi-pre-suspend = {
    description = "Unload Broadcom WiFi driver before suspend";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    script = ''
      # Unload the brcmfmac driver to prevent suspend failure
      echo "Unloading brcmfmac WiFi driver before suspend..."
      ${pkgs.kmod}/bin/modprobe -r brcmfmac_wcc || true
      ${pkgs.kmod}/bin/modprobe -r brcmfmac || true
      ${pkgs.kmod}/bin/modprobe -r brcmutil || true
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Reload WiFi driver after resume from suspend
  systemd.services.wifi-post-resume = {
    description = "Reload Broadcom WiFi driver after resume";
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    script = ''
      # Reload the brcmfmac driver after resume
      echo "Reloading brcmfmac WiFi driver after resume..."
      ${pkgs.kmod}/bin/modprobe brcmfmac || true
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
