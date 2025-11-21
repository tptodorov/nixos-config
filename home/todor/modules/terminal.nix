{
  pkgs,
  lib,
  ...
}:
{
  home = {
    packages = with pkgs; [
      # Install terminal emulators without Home Manager managing configs in standalone mode
      alacritty
    ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      ghostty
    ];

    # still configure ghostty even without installing it
    file.".config/ghostty/config" = {
      text = ''
# Empty values reset the configuration to the default value
font-family = "ZedMono NFM"
font-size =  20
theme = TokyoNight Storm
shell-integration = zsh
auto-update=download
keybind = global:cmd+option+grave_accent=toggle_quick_terminal
keybind = shift+enter=text:\n
      '';
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 10; y = 10; };
        decorations = "full";
      };
      font = {
        normal = { family = "ZedMono Nerd Font"; };
        size = 12;
      };
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
      };
    };
  };
}
