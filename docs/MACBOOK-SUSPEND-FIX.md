# MacBook Pro 2017 Suspend/Resume Fix

## Problem

The MacBook Pro 2017 has well-documented suspend/resume issues on Linux:

1. **Immediate wakeup** - System wakes immediately after suspend due to XHC1 (USB 3.0) wakeup events
2. **Slow/failed resume** - NVMe, Thunderbolt, and PCI devices fail to wake from D3 Cold power state, causing 30+ second delays or complete failure
3. **WiFi loss** - Broadcom WiFi may not restore properly after resume

## Solutions Implemented

### 1. Kernel Parameters (`hosts/pero/modules/macbook.nix`)

Added the following kernel parameters to fix ACPI suspend behavior:

```nix
boot.kernelParams = [
  "acpi=strict"              # Force proper ACPI behavior
  "mem_sleep_default=deep"   # Enable S3 sleep state
  "acpi_osi=Linux"           # Tell ACPI we're running Linux
  "acpi_backlight=video"     # Fix backlight control
];
```

### 2. Disable Problematic ACPI Wakeup Sources

Created systemd service `disable-acpi-wakeup` that disables XHC1 (USB 3.0) wakeup on boot:

```bash
# Check current wakeup sources
cat /proc/acpi/wakeup

# The service automatically disables XHC1 to prevent immediate wakeup
```

**Note:** LID0 wakeup is kept enabled by default so you can open the lid to wake. If you experience issues, you can uncomment the LID0 disabling code, but then only the power button will wake the system.

### 3. Disable D3 Cold Power State

Created systemd service `disable-d3cold` that prevents NVMe and Thunderbolt devices from entering deep sleep (D3 Cold):

```bash
# Manually check d3cold status
cat /sys/bus/pci/devices/*/d3cold_allowed

# The service sets all to 0 (disabled) on boot
```

**Trade-off:** Battery consumption during suspend is higher than macOS because power saving is disabled for these devices. This is necessary for reliable resume.

### 4. WiFi Driver Reload

Created systemd service `fix-resume` that reloads the Broadcom WiFi driver after resume:

```bash
# Manually reload WiFi if needed
sudo modprobe -r brcmfmac
sudo modprobe brcmfmac
```

### 5. TLP Configuration (`modules/profiles/laptop.nix`)

Updated TLP settings to prevent PCIe runtime power management issues:

```nix
RUNTIME_PM_ON_BAT = "on";  # Keep devices active (was "auto")
RUNTIME_PM_BLACKLIST = "01:00.0";  # Exclude NVMe from runtime PM
```

## Testing

After rebuilding the configuration on pero:

```bash
sudo nixos-rebuild switch --flake .#pero
```

Test suspend/resume:

```bash
# Check what sleep states are available
cat /sys/power/mem_sleep
# Should show: s2idle [deep]

# Test suspend
systemctl suspend

# Check for errors after resume
journalctl -b | grep -i "suspend\|resume\|acpi"

# Verify services are running
systemctl status disable-acpi-wakeup
systemctl status disable-d3cold

# Check wakeup sources
cat /proc/acpi/wakeup
# XHC1 should show as "disabled"

# Check d3cold status
cat /sys/bus/pci/devices/*/d3cold_allowed
# All should show "0"
```

## Troubleshooting

### Still getting immediate wakeup?

Uncomment the LID0 disabling code in `hosts/pero/modules/macbook.nix`:

```nix
if grep -q "^LID0.*enabled" /proc/acpi/wakeup; then
  echo LID0 > /proc/acpi/wakeup
fi
```

Note: This means only the power button will wake from suspend.

### Resume still slow?

Check for specific PCI devices causing issues:

```bash
# Check dmesg for "Unable to change power state" errors
sudo dmesg | grep -i "power state"

# Identify the specific device address and add to TLP blacklist
# Edit modules/profiles/laptop.nix and update RUNTIME_PM_BLACKLIST
```

### WiFi not working after resume?

The `fix-resume` service should handle this automatically, but you can manually reload:

```bash
sudo systemctl restart fix-resume
```

## References

- [MacBook Pro 2017 Linux Suspend/Resume Notes](https://takachin.github.io/mbp2017-linux-note/en/suspend-resume.html)
- [Arch Linux Forums - MacBook Suspend Issues](https://bbs.archlinux.org/)
- [NixOS Discourse - Suspend/Resume Issues](https://discourse.nixos.org/)

## Battery Life Impact

**Important:** These fixes prioritize reliable suspend/resume over maximum battery life. Battery drain during suspend will be higher than macOS because:

- D3 Cold power state is disabled for NVMe and Thunderbolt devices
- PCIe runtime power management is disabled on battery
- Some devices remain active during suspend

This is a necessary trade-off for a stable Linux experience on MacBook Pro 2017 hardware.
