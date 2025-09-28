{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Hyprland desktop environment configuration
  home.packages = with pkgs; [
    hyprpaper
    hypridle
    wofi
    pyprland
    pulseaudio
    hyprshot
  ];

  programs = {
    # Hyprland-related programs
    hyprlock.enable = true;
    wofi.enable = true;
    waybar.enable = true;
    waylogout.enable = true;
    wayprompt.enable = true;
  };

  services = {
    # Hyprland services
    hyprsunset.enable = true;
    hyprpaper.enable = true;
    playerctld.enable = true;

    # Notification daemon
    mako = {
      enable = true;
      settings = {
        sort = "-time";
        layer = "top";
        background-color = "#22348e";
        width = "300";
        height = "150";
        "border-size" = "0";
        "border-color" = "#72B2FE";
        "border-radius" = "15";
        padding = "20";
        icons = "1";
        "max-icon-size" = "64";
        "default-timeout" = "5000";
        "ignore-timeout" = "1";
        font = "Millimetre 10";
      };
    };
  };

  # Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    extraConfig = " # real config will be insert by the home.folder ";
  };

  # Dotfiles for Hyprland configuration
  home.file = {
    ".config/waybar" = {
      source = ../config/waybar;
      recursive = true;
    };
    ".config/asset" = {
      source = ../config/asset;
      recursive = true;
    };
    ".config/hypr" = {
      source = ../config/hypr;
      recursive = true;
    };
  };

  # Wayland environment variable
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
