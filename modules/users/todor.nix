{ config, pkgs, lib, ... }:
{
  # User account configuration for todor
  users.users.todor = {
    isNormalUser = true;
    description = "Todor Todorov";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
}