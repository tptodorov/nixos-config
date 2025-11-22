{
  config,
  pkgs,
  lib,
  ...
}:
{
  # User account configuration for todor
  users.users.todor = {
    isNormalUser = true;
    description = "Todor Todorov";
    openssh = import ../../secrets/ssh-keys.nix;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
    initialPassword = "todor";
  };

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
