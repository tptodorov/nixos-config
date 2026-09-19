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

    # This host identifies as Lenovo IdeaPad Pro 5 14IAH10 / product 83JK.
    # Do not import the nixos-hardware 14IMH9 module here; it also applies
    # model-specific display and GPU workarounds for a different chassis.

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager

    # Configuration profiles
    ../../modules/profiles/base.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/window-managers.nix
    ../../modules/profiles/gnome.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/snap.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/headscale.nix

    # Host-specific modules
    ./modules/audio.nix
    ./modules/noctalia.nix
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
      nixos = true;
    };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];
    users.todor = ../../home/todor;
  };

  # Disable nixos-hardware workaround that doesn't apply to this hardware
  # The workaround checks for a Chicony webcam, but this laptop has Bison Electronics
  systemd.services.workaround-reset-xhci-driver-after-resume-if-needed.enable = false;

  # System version
  system.stateVersion = "25.11";
}
