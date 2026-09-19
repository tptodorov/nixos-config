# Home Manager configuration for user todor
{
  config,
  lib,
  inputs,
  standalone ? false,
  nixos ? false,
  ...
}:
{
  imports = [
    # Core user modules (always included)
    ./modules/agents.nix
    ./modules/development.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/wtf.nix
  ]
  ++ lib.optionals (!standalone) [
    ./modules/dms.nix
    ./modules/desktop-apps.nix
    ./modules/brave.nix
    ./modules/media.nix
  ]
  ++ lib.optionals (!nixos) [
    ./modules/niri.nix
    ./modules/sway.nix
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
