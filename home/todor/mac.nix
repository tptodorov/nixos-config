# Home Manager configuration for user todor
{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # User modules
    ./modules/development.nix
    # ./modules/nixvim.nix
    ./modules/terminal.nix
    # ./modules/desktop-apps.nix
    # ./modules/brave.nix
    # ./modules/media.nix
    ./secrets/secrets.nix
    # ./secrets/environment.nix
  ];

  # Nixpkgs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  # Home Manager version
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
