{ config, lib, pkgs, ... }:
{
  # Media and entertainment applications
  programs = {
    spotify-player.enable = lib.mkIf (pkgs.system != "aarch64-linux") true;
  };

  services = {
    # Container services
    podman.enable = true;
  };
}
