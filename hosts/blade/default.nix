# NixOS system configuration for blade host
# Laptop for development, business, and personal work
{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # NixOS hardware optimizations for Lenovo IdeaPad 5 Pro 14IMH9
    inputs.nixos-hardware.nixosModules.lenovo-ideapad-14imh9

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager

    # Niri window manager module
    inputs.niri.nixosModules.niri

    # Configuration profiles
    ../../modules/profiles/base.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/snap.nix

    # Host-specific modules
    ./modules/kernel.nix
    ./modules/networking.nix
    ./modules/services.nix

    # Shared modules
    ../../modules/common/fonts.nix
    ../../modules/users/todor.nix

  ];

  # Home Manager configuration
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs outputs;
      laptop = true; # This is a laptop
      standalone = false; # Not standalone Home Manager
    };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];
    users.todor = ../../home/todor;
  };

  # System version
  system.stateVersion = "25.05";
}
