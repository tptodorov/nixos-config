# NixOS system configuration for blackbox host
{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager

    # System modules
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/services.nix
    ./modules/nix.nix

    # Shared modules
    ../../modules/common/fonts.nix
    ../../modules/users/todor.nix

    # Secrets
    ../../secrets/ssh-keys.nix
  ];

  # Add fenix overlay for Rust toolchain
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];

  # Home Manager configuration
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs outputs; };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];
    users.todor = ../../home/todor;
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tree
    ripgrep
    age
    sops
    efibootmgr
    inputs.home-manager.packages.${pkgs.system}.default

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

  # System version
  system.stateVersion = "25.05";
}
