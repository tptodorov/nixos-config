# Linux window-manager integration profile.
# Host configurations import this profile explicitly, just like the Noctalia
# profile, so compositor availability and user configuration share one boundary.
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.niri.nixosModules.niri ];

  programs = {
    niri = {
      enable = lib.mkDefault true;
      package = pkgs.niri-unstable;
    };
    sway = {
      enable = lib.mkDefault true;
      package = pkgs.sway;
    };
  };

  environment.systemPackages = with pkgs; [
    niri
    sway
    swaybg
    swayidle
    swaylock
  ];

  home-manager.users.todor.imports = [
    ../../home/todor/modules/niri.nix
    ../../home/todor/modules/sway.nix
    ../../home/todor/modules/mangowc.nix
  ];
}
