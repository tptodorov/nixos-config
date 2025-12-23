# Gaming configuration profile
# Provides Steam and gaming-related tools and optimizations
{
  pkgs,
  lib,
  ...
}:
{
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports for Steam Local Network Game Transfers
    gamescopeSession.enable = true; # Enable gamescope session
  };

  # Enable GameMode for performance optimization
  programs.gamemode.enable = true;

  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    # Performance monitoring
    mangohud # Vulkan and OpenGL overlay for monitoring FPS, temps, CPU/GPU load

    # Game streaming and compatibility
    gamescope # SteamOS session compositing window manager

    # Additional gaming tools
    protonup-qt # Manage Proton-GE and other compatibility tools for Steam

    # Controller support
    antimicrox # Map keyboard and mouse actions to gamepad buttons
  ];

  # Ensure 32-bit graphics support for gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for most Steam games
  };

  # Optimize system for gaming
  boot.kernel.sysctl = {
    # Increase max map count for games that need it (e.g., some Windows games via Proton)
    "vm.max_map_count" = 2147483642;
  };
}
