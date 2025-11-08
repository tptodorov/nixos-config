{ config, lib, pkgs, vm ? false, ... }:
{
  # Media and entertainment applications
  home.packages = with pkgs; [
    vlc # Video player
  ];

  programs = {
    spotify-player.enable = !vm;
  };

  services = {
    # Container services
    podman.enable = true;
  };
}
