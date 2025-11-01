{ config, lib, pkgs, vm ? false, ... }:
{
  # Media and entertainment applications
  programs = {
    spotify-player.enable = !vm;
  };

  services = {
    # Container services
    podman.enable = true;
  };
}
