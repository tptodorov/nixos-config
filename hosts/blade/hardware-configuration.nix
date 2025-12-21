# Hardware configuration for blade
# This is a placeholder file that should be replaced with the actual hardware configuration
# after NixOS installation.
#
# To generate the actual hardware configuration on the target machine, run:
#   nixos-generate-config --show-hardware-config > hosts/blade/hardware-configuration.nix
#
# Or during installation:
#   nixos-generate-config --root /mnt
#   # Then copy /mnt/etc/nixos/hardware-configuration.nix to this file

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules (placeholder - will be auto-detected)
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];  # Change to "kvm-amd" for AMD processors
  boot.extraModulePackages = [ ];

  # File systems (placeholder - MUST be replaced with actual configuration)
  # IMPORTANT: Replace these placeholder values with actual UUIDs after installation
  # Run: blkid /dev/sdXY to get the UUID of your partitions
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Swap configuration (uncomment and configure if needed)
  # swapDevices = [
  #   { device = "/dev/disk/by-uuid/PLACEHOLDER-SWAP-UUID"; }
  # ];

  # Networking hardware
  networking.useDHCP = lib.mkDefault true;

  # CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # For AMD processors, use:
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Graphics and hardware acceleration
  hardware.graphics.enable = true;

  # System architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

