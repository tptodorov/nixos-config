{
  config,
  pkgs,
  lib,
  ...
}:
{
  # System-wide font configuration
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.inconsolata
    nerd-fonts.zed-mono
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
  ];
}
