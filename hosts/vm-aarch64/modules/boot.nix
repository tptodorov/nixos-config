{ config, pkgs, lib, ... }:
{
  # Import blackbox boot configuration and add VM-specific settings
  imports = [
    ../../blackbox/modules/boot.nix
  ];

  # VM-specific kernel modules (VMware modules not available on aarch64)
  # boot.initrd.availableKernelModules = [
  #   "vmw_pvscsi"   # Not available on aarch64-linux
  #   "vmw_vmci"     # Not available on aarch64-linux
  #   "vmw_balloon"  # Not available on aarch64-linux
  #   "vmwgfx"       # Not available on aarch64-linux
  # ];
}