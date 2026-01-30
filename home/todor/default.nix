# Home Manager configuration for user todor
{
  config,
  lib,
  inputs,
  standalone ? false,
  ...
}:
{
  imports = [
    # Core user modules (always included)
    ./modules/development.nix
    ./modules/nixvim.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./secrets/secrets.nix
  ] ++ lib.optionals (!standalone) [
    # Desktop modules (only for NixOS, not for standalone Home Manager)
    ./modules/niri.nix
    ./modules/mangowc.nix
    ./modules/cosmic.nix
    ./modules/desktop-apps.nix
    ./modules/brave.nix
    ./modules/media.nix
    ./modules/dankmaterialshell.nix
  ];

  # Nixpkgs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # User information
  home.username = lib.mkDefault "todor";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  # Home Manager version
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
