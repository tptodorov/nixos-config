# Nix store and garbage collection configuration
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Import blackbox nix configuration
  imports = [
    ../../blackbox/modules/nix.nix
  ];
  # VM-specific overrides (if any needed)
  # All nix configuration inherited from blackbox
}
