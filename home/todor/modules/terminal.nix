{ config, lib, pkgs, ... }:
{
  # Terminal and shell configuration
  home.packages = with pkgs; [
    dua
    nixfmt-rfc-style
    nixfmt-tree
  ];

  programs = {
    # Terminal emulators
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = "TokyoNight Storm";
        font-size = 12;
        font-family = "ZedMono Nerd Font";
      };
    };

    rio.enable = true;
    kitty.enable = true;

    # Shell and utilities
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
      };
    };

    # CLI tools
    ripgrep.enable = true;
    htop.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    eza.enable = true;
    starship.enable = true;
    fastfetch.enable = true;

    # SSH
    ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };

  # GPG and SSH services
  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
  };
}