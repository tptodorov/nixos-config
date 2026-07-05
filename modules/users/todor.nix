{
  pkgs,
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
      "scanner" # For scanner access
      "lp" # For printer access
      "docker" # For Docker access
      "video" # For camera/webcam access
      "input" # For Voxtype modifier-release guard
      "ydotool" # For GNOME Wayland keyboard simulation
    ];
    shell = pkgs.zsh;
    initialPassword = "todor";
  };

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
