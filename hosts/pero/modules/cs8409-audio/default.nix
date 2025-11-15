{ config, lib, pkgs, inputs, ... }:

{
  # Import nixos-hardware MacBook Pro 14-1 base configuration
  imports = [
    inputs.nixos-hardware.nixosModules.apple-macbook-pro-14-1
  ];

  # Build and load the custom audio driver
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ./driver.nix { })
  ];

  # Blacklist the default CS8409 driver to prevent conflicts
  boot.blacklistedKernelModules = [ "snd_hda_codec_cs8409" ];

  # The custom driver will be loaded automatically when needed
}
