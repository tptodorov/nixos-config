# NixOS system configuration for blackbox host
{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager

    # Configuration profiles
    ../../modules/profiles/base.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/window-managers.nix
    ../../modules/profiles/gnome.nix
    ../../modules/profiles/snap.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/headscale.nix
    ../../modules/profiles/services.nix

    # Host-specific modules
    ./modules/kernel.nix
    ./modules/noctalia.nix
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
      laptop = false;
      standalone = false; # Not standalone Home Manager
      nixos = true;
    };
    users.todor = ../../home/todor;
  };

  # System version
  system.stateVersion = "25.11";
}
