{ config, pkgs, lib, ... }:
{
  # Import blackbox services and override for VM
  imports = [
    ../../blackbox/modules/services.nix
  ];

  # VM-specific overrides - disable audio services
  security.rtkit.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio.enable = lib.mkForce false;
}
