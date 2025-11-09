{ config, pkgs, lib, ... }:

{
  # APFS support for reading Mac-formatted drives
  # Provides both kernel module and FUSE-based support

  # Install APFS kernel module (read-only, experimental)
  # This enables native APFS support in the kernel
  boot.extraModulePackages = with config.boot.kernelPackages; [
    apfs
  ];

  # Automatically load the APFS kernel module at boot
  boot.kernelModules = [ "apfs" ];

  # Install APFS userspace tools
  environment.systemPackages = with pkgs; [
    # FUSE-based APFS driver (read-only, more stable fallback)
    apfs-fuse

    # APFS filesystem utilities (mkfs, fsck, etc.)
    apfsprogs

    # APFS compression/decompression tool (Darwin only, conditionally included)
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.afsctool
  ];

  # Add filesystem support for automatic mounting
  boot.supportedFilesystems = [ "apfs" ];

  # Note: APFS support in Linux is currently read-only
  # To mount an APFS volume manually:
  #   sudo mount -t apfs /dev/sdX /mnt/apfs
  #
  # Or using FUSE (fallback if kernel module has issues):
  #   apfs-fuse /dev/sdX /mnt/apfs
}
