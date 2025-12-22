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

    # Niri window manager module
    inputs.niri.nixosModules.niri

    # Configuration profiles
    ../../modules/profiles/base.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/apfs.nix
    ../../modules/profiles/snap.nix

    # Host-specific modules
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
      standalone = false;  # Not standalone Home Manager
    };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];
    users.todor = ../../home/todor;
  };

  # System version
  system.stateVersion = "25.05";
}
