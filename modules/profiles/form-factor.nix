# Form factor-specific configuration
# This module consolidates desktop vs laptop distinctions
{
  config,
  lib,
  ...
}:
{
  # Form factor is determined per-host in flake.nix specialArgs
  # Available values: "desktop", "laptop"
  options.formFactor = lib.mkOption {
    type = lib.types.enum [ "desktop" "laptop" ];
    default = "desktop";
    description = "System form factor (desktop or laptop)";
  };

  config = lib.mkMerge [
    # Laptop-specific settings
    (lib.mkIf (config.formFactor == "laptop") {
      services.tlp.enable = true;
      services.thermald.enable = lib.mkDefault true;
      services.libinput.enable = true;
      programs.light.enable = true;

      environment.systemPackages = with pkgs; [
        acpi
        powertop
        brightnessctl
      ];
    })

    # Desktop-specific settings
    (lib.mkIf (config.formFactor == "desktop") {
      # Disable laptop-specific services
      services.tlp.enable = lib.mkForce false;
      services.thermald.enable = lib.mkForce false;
    })
  ];
}
