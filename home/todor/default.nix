# Home Manager configuration for user todor
{
  config,
  lib,
  ...
}:
{
  imports = [
    # User modules
    ./modules/development.nix
    ./modules/nixvim.nix
    ./modules/terminal.nix
    ./modules/desktop-apps.nix
    ./modules/brave.nix
    ./modules/hyprland.nix
    ./modules/media.nix
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
