# Home Manager configuration for user todor
{
  config,
  lib,
  pkgs,
  inputs,
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
    overlays = [ inputs.fenix.overlays.default ];
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

  # Packages managed by Home Manager
  home.packages = with pkgs; [
    vim
    wget
    git
    tree
    ripgrep

    # Rust toolchain via fenix
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
