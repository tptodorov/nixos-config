{ config, lib, pkgs, ... }:
{
  # Media and entertainment applications
  programs = {
    spotify-player.enable = true;
  };

  services = {
    # Container services
    podman.enable = true;
  };
}
