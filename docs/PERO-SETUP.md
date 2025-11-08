# Setting Up NixOS on Pero (MacBook Pro 13" 2017)

This guide walks you through installing NixOS on the "pero" MacBook Pro using the pre-configured setup from this repository.

## Prerequisites

- MacBook Pro 13" 2017
- USB drive (8GB+ recommended) for NixOS installation media
- Backup of any important data (installation will erase the drive)
- Internet connection

## Step 1: Create NixOS Installation Media

On another machine (e.g., blackbox):

```bash
# Download the latest NixOS ISO
# Visit https://nixos.org/download.html and get the GNOME ISO for x86_64

# Write to USB drive (replace /dev/sdX with your USB drive)
sudo dd if=nixos-gnome-*.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

## Step 2: Boot from USB on MacBook

1. Insert the USB drive into the MacBook
2. Restart the MacBook
3. Hold down the **Option/Alt** key during startup
4. Select the USB drive (EFI Boot) from the boot menu
5. Boot into the NixOS installer

## Step 3: Partition the Drive

The MacBook Pro typically has a single NVMe SSD. We'll create:
- EFI boot partition (512MB)
- Root partition (remaining space)
- Optional: Swap partition (8-16GB recommended for suspend-to-disk)

```bash
# List disks to find your NVMe drive
lsblk

# Use parted to partition (assuming /dev/nvme0n1)
sudo parted /dev/nvme0n1

# In parted:
(parted) mklabel gpt
(parted) mkpart ESP fat32 1MiB 512MiB
(parted) set 1 esp on
(parted) mkpart primary 512MiB 16GiB      # Swap (optional)
(parted) mkpart primary 16GiB 100%         # Root
(parted) quit

# Format partitions
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L nixos /dev/nvme0n1p3

# Mount partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
sudo swapon /dev/disk/by-label/swap
```

## Step 4: Clone Your Configuration

```bash
# Connect to WiFi (if needed)
sudo systemctl start wpa_supplicant
wpa_cli

# In wpa_cli:
> add_network
> set_network 0 ssid "YourWiFiName"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit

# Clone your configuration repository
cd /mnt
sudo mkdir -p /mnt/home/todor
cd /mnt/home/todor
sudo git clone https://github.com/yourusername/mycfg.git
# Or copy from USB drive if you have it prepared
```

## Step 5: Generate Hardware Configuration

```bash
# Generate hardware configuration
sudo nixos-generate-config --root /mnt --show-hardware-config > /tmp/hardware-config.nix

# Copy it to the pero configuration
sudo cp /tmp/hardware-config.nix /mnt/home/todor/mycfg/hosts/pero/hardware-configuration.nix

# Important: Verify the hardware config has the correct settings
sudo nano /mnt/home/todor/mycfg/hosts/pero/hardware-configuration.nix

# Make sure it includes:
# - nixpkgs.hostPlatform = "x86_64-linux";
# - Correct partition labels/UUIDs matching what you created
```

## Step 6: Install NixOS

```bash
# Navigate to config directory
cd /mnt/home/todor/mycfg

# Add the updated hardware-configuration.nix to git
git add hosts/pero/hardware-configuration.nix

# Install NixOS using the pero configuration
sudo nixos-install --flake .#pero

# Set root password when prompted
# Note: User 'todor' already has password 'todor' set in the config

# Installation may take 30-60 minutes depending on internet speed
```

## Step 7: First Boot

```bash
# Reboot
sudo reboot

# Remove the USB drive when prompted
# Boot into NixOS
```

## Step 8: Post-Installation

After booting into NixOS:

1. **Login**: Username: `todor`, Password: `todor`

2. **Connect to WiFi**:
   - Use NetworkManager applet in the system tray
   - Or: `nmtui` in terminal

3. **Update and Configure**:
   ```bash
   cd ~/mycfg

   # Update the configuration if needed
   sudo nixos-rebuild switch --flake .#pero

   # Update flake inputs (optional)
   nix flake update
   sudo nixos-rebuild switch --flake .#pero
   ```

4. **Choose Your Window Manager**:
   - Log out
   - At the login screen (GDM), click the gear icon
   - Select your preferred session:
     - **Niri** - Scrollable tiling compositor (recommended for laptops)
     - **Hyprland** - Dynamic tiling compositor
     - **GNOME** - Traditional desktop
     - **COSMIC** - Modern Rust-based desktop

5. **Verify Hardware**:
   ```bash
   # Check WiFi
   nmcli device status

   # Check battery
   acpi -b

   # Check sensors
   sensors

   # Check graphics
   glxinfo | grep "OpenGL renderer"
   ```

## Troubleshooting

### WiFi Not Working

If WiFi doesn't work after installation, you may need to enable Broadcom drivers:

1. Edit `hosts/pero/hardware-configuration.nix`:
   ```nix
   # Add to nixpkgs.config
   nixpkgs.config.permittedInsecurePackages = [
     "broadcom-sta-6.30.223.271-57-6.12.57"
   ];

   # Uncomment in boot section:
   boot.kernelModules = [ "kvm-intel" "wl" ];
   boot.extraModulePackages = with config.boot.kernelPackages; [
     broadcom_sta
   ];
   ```

2. Rebuild: `sudo nixos-rebuild switch --flake .#pero`

### Display Scaling Issues

The Retina display defaults to 2x scaling. To adjust:

1. Edit `hosts/pero/modules/macbook.nix`
2. Modify `GDK_SCALE` and related environment variables
3. Rebuild

### Touchpad Not Responsive

Check libinput settings in `modules/profiles/laptop.nix` and adjust sensitivity as needed.

### Battery Life

The laptop profile includes TLP for power management. To monitor:

```bash
# Check TLP status
sudo tlp-stat

# Monitor power consumption
sudo powertop
```

## Next Steps

- Configure your dotfiles and preferences
- Set up iCloud integration (see `docs/ICLOUD-SETUP.md`)
- Customize window manager keybindings
- Install additional applications as needed
- Change the default password: `passwd`

## MacBook-Specific Features

The pero configuration includes:
- **Power Management**: TLP configured for battery optimization
- **Touchpad**: Natural scrolling, tap-to-click enabled
- **Keyboard**: Function keys set to work as F-keys by default (not media keys)
- **Display**: HiDPI settings for Retina display (2560x1600)
- **Thermal Management**: Intel thermald for CPU temperature control
- **Hardware Acceleration**: Intel VA-API drivers for video playback

Enjoy your NixOS-powered MacBook Pro!
