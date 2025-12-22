# Snap package manager support
# Enables installation of snap packages alongside Nix packages
# Import this module in hosts that need snap support

{ config, pkgs, lib, inputs, ... }:

{
  # Import nix-snapd NixOS module
  imports = [
    inputs.nix-snapd.nixosModules.default
  ];

  # Enable snap service
  services.snap.enable = true;

  # Optional: Add snap binaries to PATH for all users
  environment.variables = {
    PATH = [ "/snap/bin" ];
  };

  # Optional: Ensure snapd socket is enabled
  systemd.sockets.snapd = {
    wantedBy = [ "sockets.target" ];
  };
}
