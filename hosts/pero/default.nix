# NixOS system configuration for pero host (MacBook Pro 13" 2017)
{
  inputs,
  outputs,
  pkgs,
  vm ? false,
  ...
}:
{
  imports = [
    # Hardware configuration (to be generated on pero)
    ./hardware-configuration.nix

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager

    # Configuration profiles
    ../../modules/profiles/base.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/desktop.nix  # Include full desktop environment
    ../../modules/profiles/apfs.nix

    # Host-specific modules
    ./modules/macbook.nix
    # ./modules/cs8409-audio  # Temporarily disabled - driver build failing

    # Shared modules
    ../../modules/common/fonts.nix
    ../../modules/users/todor.nix

    # Secrets
    ../../secrets/ssh-keys.nix
  ];

  # Hostname
  networking.hostName = "pero";

  # Home Manager configuration
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs outputs vm; laptop = true; };
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
