{
  pkgs,
  lib,
  laptop ? false,
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
        font-style = Regular
        font-style-bold = ExtraBold
        font-style-italic = Italic
        font-style-bold-italic = ExtraBold Italic
        font-size = ${if laptop then "14" else "20"}

        # Theme
        theme = TokyoNight

        # Shell integration
        shell-integration = zsh
        shell-integration-features = cursor,sudo,title

        # Updates
        auto-update = download

        # Resize overlay configuration
        resize-overlay = never
        resize-overlay-position = center

        # Terminal behavior
        confirm-close-surface = false
        quit-after-last-window-closed = false

        # ═══════════════════════════════════════════════════════════════
        # Key Bindings - Cross-platform Ctrl+Shift based
        # ═══════════════════════════════════════════════════════════════

        # Global / Special
        keybind = global:cmd+option+grave_accent=toggle_quick_terminal
        keybind = shift+enter=text:\n

        # ── Clipboard ──────────────────────────────────────────────────
        keybind = ctrl+shift+c=copy_to_clipboard
        keybind = ctrl+shift+v=paste_from_clipboard
        keybind = ctrl+shift+u=copy_url_to_clipboard

        # ── Font Size ──────────────────────────────────────────────────
        keybind = ctrl+shift+equal=increase_font_size:1
        keybind = ctrl+shift+minus=decrease_font_size:1
        keybind = ctrl+shift+digit_0=reset_font_size

        # ── Tabs ───────────────────────────────────────────────────────
        keybind = ctrl+shift+t=new_tab
        keybind = ctrl+shift+w=close_surface
        keybind = ctrl+shift+page_up=previous_tab
        keybind = ctrl+shift+page_down=next_tab
        keybind = ctrl+shift+home=goto_tab:1
        keybind = ctrl+shift+end=last_tab
        keybind = ctrl+shift+digit_1=goto_tab:1
        keybind = ctrl+shift+digit_2=goto_tab:2
        keybind = ctrl+shift+digit_3=goto_tab:3
        keybind = ctrl+shift+digit_4=goto_tab:4
        keybind = ctrl+shift+digit_5=goto_tab:5
        keybind = ctrl+shift+digit_6=goto_tab:6
        keybind = ctrl+shift+digit_7=goto_tab:7
        keybind = ctrl+shift+digit_8=goto_tab:8
        keybind = ctrl+shift+digit_9=goto_tab:9

        # ── Splits ─────────────────────────────────────────────────────
        keybind = ctrl+shift+d=new_split:right
        keybind = ctrl+shift+e=new_split:down
        keybind = ctrl+shift+x=close_surface
        keybind = ctrl+shift+z=toggle_split_zoom
        keybind = ctrl+shift+backslash=equalize_splits

        # Split Navigation (vim-style)
        keybind = ctrl+shift+h=goto_split:left
        keybind = ctrl+shift+l=goto_split:right
        keybind = ctrl+shift+k=goto_split:up
        keybind = ctrl+shift+j=goto_split:down
        keybind = ctrl+shift+bracket_left=goto_split:previous
        keybind = ctrl+shift+bracket_right=goto_split:next

        # Split Resizing
        keybind = ctrl+shift+arrow_left=resize_split:left,20
        keybind = ctrl+shift+arrow_right=resize_split:right,20
        keybind = ctrl+shift+arrow_up=resize_split:up,10
        keybind = ctrl+shift+arrow_down=resize_split:down,10

        # ── Windows ────────────────────────────────────────────────────
        keybind = ctrl+shift+n=new_window
        keybind = ctrl+shift+q=close_window
        keybind = ctrl+shift+f=toggle_fullscreen
        keybind = ctrl+shift+m=toggle_maximize

        # ── Scrolling ──────────────────────────────────────────────────
        keybind = ctrl+shift+s=scroll_to_top
        keybind = ctrl+shift+b=scroll_to_bottom
        keybind = ctrl+shift+g=scroll_to_selection

        # ── Search ─────────────────────────────────────────────────────
        keybind = ctrl+shift+slash=start_search
        keybind = ctrl+shift+r=search_selection

        # ── Screen ─────────────────────────────────────────────────────
        keybind = ctrl+shift+a=select_all
        keybind = ctrl+shift+backspace=clear_screen
        keybind = ctrl+shift+i=reset

        # ── Utilities ──────────────────────────────────────────────────
        keybind = ctrl+shift+p=toggle_command_palette
        keybind = ctrl+shift+o=open_config
        keybind = ctrl+shift+f5=reload_config
        keybind = ctrl+shift+y=toggle_readonly
        keybind = ctrl+shift+period=inspector:toggle
      '';
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      # Window settings
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
        dynamic_padding = true;
      };

      # Font configuration - matching Kitty and Ghostty
      font = {
        normal = {
          family = "ZedMono Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "ZedMono Nerd Font Mono";
          style = "ExtraBold";
        };
        italic = {
          family = "ZedMono Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "ZedMono Nerd Font Mono";
          style = "ExtraBold Italic";
        };
        size = if laptop then 14 else 20;
      };

      # Cursor - matching Kitty
      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
        unfocused_hollow = true;
      };

      # Selection
      selection = {
        save_to_clipboard = true;
      };

      # Tokyo Night theme colors - matching Kitty
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        cursor = {
          text = "#1a1b26";
          cursor = "#c0caf5";
        };
        selection = {
          text = "#c0caf5";
          background = "#283457";
        };
        # Normal colors
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        # Bright colors
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
        # Indexed colors (extended)
        indexed_colors = [
          {
            index = 16;
            color = "#ff9e64";
          }
          {
            index = 17;
            color = "#db4b4b";
          }
        ];
      };

      # Keybindings - Ctrl+Shift based like Ghostty
      keyboard = {
        bindings = [
          # Clipboard
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }

          # Font size
          {
            key = "Equals";
            mods = "Control|Shift";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Control|Shift";
            action = "DecreaseFontSize";
          }
          {
            key = "Key0";
            mods = "Control|Shift";
            action = "ResetFontSize";
          }

          # Tabs (Alacritty doesn't have native tabs, but we keep bindings for reference)
          {
            key = "N";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }

          # Scrolling
          {
            key = "PageUp";
            mods = "Shift";
            action = "ScrollPageUp";
          }
          {
            key = "PageDown";
            mods = "Shift";
            action = "ScrollPageDown";
          }
          {
            key = "Home";
            mods = "Shift";
            action = "ScrollToTop";
          }
          {
            key = "End";
            mods = "Shift";
            action = "ScrollToBottom";
          }

          # Search
          {
            key = "F";
            mods = "Control|Shift";
            action = "SearchForward";
          }
          {
            key = "B";
            mods = "Control|Shift";
            action = "SearchBackward";
          }

          # Toggle fullscreen
          {
            key = "F";
            mods = "Control|Shift|Alt";
            action = "ToggleFullscreen";
          }

          # Vi mode
          {
            key = "Space";
            mods = "Control|Shift";
            action = "ToggleViMode";
          }
        ];
      };

      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Terminal settings
      terminal = {
        shell = {
          program = "zsh";
        };
      };

      # Mouse
      mouse = {
        hide_when_typing = true;
      };

      # Hints (URL detection)
      hints = {
        enabled = [
          {
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
            hyperlinks = true;
            command = "xdg-open";
            post_processing = true;
            mouse = {
              enabled = true;
              mods = "None";
            };
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
          }
        ];
      };
    };
  };
  programs.kitty = {
    enable = true;
    settings = {
      # Fonts - Regular for normal, ExtraBold for bold to maximize contrast
      font_family = "ZedMono Nerd Font Mono";
      font_size = if laptop then 14 else 20;
      bold_font = "ZedMono Nerd Font Mono Bold";
      italic_font = "ZedMono Nerd Font Mono Italic";
      bold_italic_font = "ZedMono Nerd Font Mono Bold Italic";

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
      macos_thicken_font = 0.0;

      tab_title_template = "{session_name} {title}";
    };

    # Use predefined Tokyo Night theme
    themeFile = "tokyo_night_night";

    # Key mappings
    keybindings = {
      "ctrl+shift+enter" = "launch --location=split --cwd=last_reported";
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+l" = "next_layout";
      "f7>/" = "goto_session";
      "f7>l" = "goto_session langcache";
      "f7>n" = "goto_session nixos";
      "f7>-" = "goto_session -1";
      "kitty_mod+a" = "launch zsh -c  'direnv exec ~/redislabsdev/langcache auggie'";
    };
  };
}
