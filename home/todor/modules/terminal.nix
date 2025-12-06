{
  pkgs,
  lib,
  ...
}:
{
  home = {
    packages =
      with pkgs;
      [
        # Install terminal emulators without Home Manager managing configs in standalone mode
        alacritty
        kitty
      ]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        ghostty
      ];

    # still configure ghostty even without installing it
    file.".config/ghostty/config" = {
      text = ''
        # Font configuration
        font-family = "ZedMono Nerd Font Mono"
        font-size = 20

        # Theme
        theme = TokyoNight Storm

        # Shell integration
        shell-integration = zsh
        shell-integration-features = cursor,sudo,title

        # Updates
        auto-update = download

        # Disable problematic features that cause parse errors
        resize-overlay = false
        resize-overlay-position = center

        # Terminal behavior
        confirm-close-surface = false
        quit-after-last-window-closed = false

        # Key bindings
        keybind = global:cmd+option+grave_accent=toggle_quick_terminal
        keybind = shift+enter=text:\n
      '';
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
      };
      font = {
        normal = {
          family = "ZedMono Nerd Font Mono";
        };
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
  programs.kitty = {
    enable = true;
    settings = {
      # Fonts
      font_family = "ZedMono Nerd Font Mono";
      font_size = 18;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      # Cursor customization
      cursor_shape = "block";
      cursor_beam_thickness = 1.5;
      cursor_underline_thickness = 2.0;
      cursor_stop_blinking_after = 15.0;

      # Mouse
      copy_on_select = true;

      # Window layout
      enabled_layouts = "*";

      # macOS specific
      macos_option_as_alt = true;
      macos_thicken_font = 0;

      # Keyboard shortcuts
      # kitty_mod = "ctrl+shift";

      # Tokyo Night theme colors
      background = "#1a1b26";
      foreground = "#c0caf5";
      selection_background = "#283457";
      selection_foreground = "#c0caf5";
      url_color = "#73daca";
      cursor = "#c0caf5";
      cursor_text_color = "#1a1b26";

      # Tabs
      active_tab_background = "#7aa2f7";
      active_tab_foreground = "#16161e";
      inactive_tab_background = "#292e42";
      inactive_tab_foreground = "#545c7e";

      # Windows
      active_border_color = "#7aa2f7";
      inactive_border_color = "#292e42";

      # Normal colors
      color0 = "#15161e";
      color1 = "#f7768e";
      color2 = "#9ece6a";
      color3 = "#e0af68";
      color4 = "#7aa2f7";
      color5 = "#bb9af7";
      color6 = "#7dcfff";
      color7 = "#a9b1d6";

      # Bright colors
      color8 = "#414868";
      color9 = "#f7768e";
      color10 = "#9ece6a";
      color11 = "#e0af68";
      color12 = "#7aa2f7";
      color13 = "#bb9af7";
      color14 = "#7dcfff";
      color15 = "#c0caf5";

      # Extended colors
      color16 = "#ff9e64";
      color17 = "#db4b4b";
    };

    # Key mappings
    keybindings = {
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+l" = "next_layout";
    };
  };
}
