{ config, pkgs, lib, ... }:
{
  # Import blackbox networking and override for VM
  imports = [
    ../../blackbox/modules/networking.nix
  ];

  # VM-specific overrides
  networking.hostName = lib.mkForce "vm-aarch64";

  # Allow root login for VM management
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
}
