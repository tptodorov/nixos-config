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
    ./secrets/secrets.nix
  ] ++ lib.optionals (!standalone) [

    ./modules/terminal.nix
  ] ;

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
