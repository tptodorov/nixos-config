# NixOS system configuration for pero host (MacBook Pro 13" 2017)
{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    # Hardware configuration (to be generated on pero)
    ./hardware-configuration.nix

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager

    # Niri window manager module
    inputs.niri.nixosModules.niri

    # Configuration profiles
    ../../modules/profiles/base.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/desktop.nix # Include full desktop environment
    ../../modules/profiles/apfs.nix

    # Host-specific modules
    ./modules/macbook.nix

    # Shared modules
    ../../modules/common/fonts.nix
    ../../modules/users/todor.nix

  ];

  # Hostname
  networking.hostName = "pero";

  # Home Manager configuration
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs outputs;
      laptop = true;
      vm = false;
      standalone = true;
    };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];
    users.todor = ../../home/todor;
  };

  # MacBook-specific hardware support
  hardware = {
    # Enable all firmware (including proprietary)
    enableAllFirmware = true;

    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };

  # Firmware for Broadcom WiFi (common in MacBooks)
  nixpkgs.config.allowUnfree = true;

  # System version
  system.stateVersion = "25.05";
}
