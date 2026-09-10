{
  pkgs,
  laptop ? false,
  ...
}:
let
  weztermConfig = ''
    local wezterm = require("wezterm")
    local act = wezterm.action
    local config = wezterm.config_builder()


    -- REQUIRED: Connect to unix mux server on startup
    -- This ensures WEZTERM_UNIX_SOCKET is consistent across all panes
    config.default_gui_startup_args = { 'connect', 'unix' }

    -- REQUIRED: Configure unix_domains for the mux server
    config.unix_domains = {
      { name = 'unix' },
    }

    config.font_dirs = { "${pkgs.nerd-fonts.zed-mono}/share/fonts/truetype/NerdFonts/ZedMono" }
    config.font = wezterm.font { family = "ZedMono Nerd Font Mono" }
    config.font_size = ${if laptop then "14" else "20"}

    config.color_scheme = "Catppuccin Macchiato"
    config.inactive_pane_hsb = {
      saturation = 0.75,
      brightness = 0.55,
    }
    config.colors = {
      split = "#f5a97f",
    }

    config.default_prog = { "zsh" }
    config.enable_wayland = true
    config.window_close_confirmation = "NeverPrompt"
    config.window_padding = {
      left = 14,
      right = 14,
      top = 12,
      bottom = 12,
    }
    config.cursor_blink_rate = 0
    config.default_cursor_style = "SteadyBlock"
    config.hide_mouse_cursor_when_typing = true
    config.scrollback_lines = 10000
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
    config.enable_kitty_keyboard = true
    config.window_decorations = "RESIZE"
    config.use_fancy_tab_bar = false
    config.tab_bar_at_bottom = true
    config.tab_max_width = 64
    config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 1000 }

    local split_right = act.SplitHorizontal({ domain = "CurrentPaneDomain" })
    local split_down = act.SplitVertical({ domain = "CurrentPaneDomain" })

    wezterm.on("format-tab-title", function(tab)
      local title = tab.tab_title
      if title == nil or title == "" then
        title = tab.active_pane.title
      end
      if title == nil or title == "" then
        title = "zsh"
      end
      local workspace = wezterm.mux.get_active_workspace()
      if workspace == nil or workspace == "" or workspace == "default" then
        return " " .. title .. " "
      end
      return " " .. workspace .. " " .. title .. " "
    end)

    config.keys = {
      {
        key = "phys:Space",
        mods = "CTRL|SHIFT",
        action = act.DisableDefaultAssignment,
      },
      -- WORKAROUND: WezTerm's built-in PasteFrom("Clipboard") action doesn't
      -- reliably reach panes attached via a unix-domain mux connection (see
      -- https://github.com/wezterm/wezterm/issues/3968). Shell out to
      -- pbpaste and inject the text directly instead.
      {
        key = "v",
        mods = "SUPER",
        action = wezterm.action_callback(function(window, pane)
          local success, stdout = wezterm.run_child_process({ "pbpaste" })
          if success then
            window:perform_action(act.SendString(stdout), pane)
          end
        end),
      },
      -- CORRECT: Uses the current pane's domain (mux server)
      { key = 't', mods = 'SUPER', action = act.SpawnTab('CurrentPaneDomain') },
      {
        key = "Tab",
        mods = "CTRL",
        action = act.ActivateTabRelative(1),
      },
      {
        key = "Tab",
        mods = "CTRL|SHIFT",
        action = act.ActivateTabRelative(-1),
      },
      {
        key = "LeftArrow",
        mods = "CTRL|SHIFT",
        action = act.ActivatePaneDirection("Left"),
      },
      {
        key = "RightArrow",
        mods = "CTRL|SHIFT",
        action = act.ActivatePaneDirection("Right"),
      },
      {
        key = "UpArrow",
        mods = "CTRL|SHIFT",
        action = act.ActivatePaneDirection("Up"),
      },
      {
        key = "DownArrow",
        mods = "CTRL|SHIFT",
        action = act.ActivatePaneDirection("Down"),
      },
      {
        key = "Enter",
        mods = "SHIFT",
        action = act.SendString("\x1b[13;2u"),
      },
      {
        key = "Enter",
        mods = "CTRL|SHIFT",
        action = split_right,
      },
      {
        key = "Enter",
        mods = "SUPER|SHIFT",
        action = split_right,
      },
      {
        key = "Enter",
        mods = "CTRL|SHIFT|ALT",
        action = split_down,
      },
      {
        key = "Enter",
        mods = "SUPER|SHIFT|ALT",
        action = split_down,
      },
      {
        key = "l",
        mods = "CTRL|SHIFT",
        action = act.RotatePanes("Clockwise"),
      },
      {
        key = "a",
        mods = "CTRL|SHIFT",
        action = act.SplitPane({
          command = { args = { "zsh", "-l", "-i", "-c", "codex" },},
          direction = "Right",
        }),
      },
      {
        key = "c",
        mods = "CTRL|SHIFT",
        action = act.SplitPane({
          command = { args = { "zsh", "-l", "-i", "-c", "claude --permission-mode auto" },},
          direction = "Right",
        }),
      },
      {
        key = "w",
        mods = "LEADER",
        action = act.SpawnCommandInNewTab({
          args = { "zsh", "-l", "-i", "-c", "workmux dashboard" },
        }),
      },
      {
        key = "d",
        mods = "LEADER",
        action = act.SpawnCommandInNewTab({
          args = { "zsh", "-l", "-i", "-c", "workmux dashboard -d" },
        }),
      },
    }

    return config
  '';
in
{
  home = {
    packages = with pkgs; [
      kitty
      wezterm
    ];

    file = {
      ".config/wezterm/wezterm.lua".text = weztermConfig;
      ".wezterm.lua".text = weztermConfig;
    };
  };

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      command = "zsh";
      theme = "Catppuccin Macchiato";
      "font-family" = "ZedMono Nerd Font Mono";
      "font-size" = if laptop then 14 else 20;

      "cursor-style" = "block";
      "cursor-style-blink" = false;
      "mouse-hide-while-typing" = true;
      "scrollback-limit" = 10000000;

      "window-padding-x" = 14;
      "window-padding-y" = 12;
      "window-show-tab-bar" = "always";
      "window-new-tab-position" = "end";
      "window-inherit-working-directory" = true;
      "tab-inherit-working-directory" = true;
      "split-inherit-working-directory" = true;
      "confirm-close-surface" = false;

      "macos-option-as-alt" = true;
      "shell-integration" = "zsh";

      "split-divider-color" = "#f5a97f";
      "unfocused-split-opacity" = 0.75;

      keybind = [
        "super+v=paste_from_clipboard"
        "super+t=new_tab"
        "ctrl+tab=next_tab"
        "ctrl+shift+tab=previous_tab"

        "ctrl+shift+arrow_left=goto_split:left"
        "ctrl+shift+arrow_right=goto_split:right"
        "ctrl+shift+arrow_up=goto_split:up"
        "ctrl+shift+arrow_down=goto_split:down"

        "shift+enter=csi:13;2u"
        "ctrl+shift+enter=new_split:right"
        "super+shift+enter=new_split:right"
        "ctrl+alt+shift+enter=new_split:down"
        "super+alt+shift+enter=new_split:down"

        "ctrl+shift+space>1=goto_tab:1"
        "ctrl+shift+space>2=goto_tab:2"
        "ctrl+shift+space>3=goto_tab:3"
        "ctrl+shift+space>4=goto_tab:4"
        "ctrl+shift+space>5=goto_tab:5"
        "ctrl+shift+space>6=goto_tab:6"
        "ctrl+shift+space>7=goto_tab:7"
        "ctrl+shift+space>8=goto_tab:8"
        "ctrl+shift+space>9=goto_tab:9"

        "global:cmd+option+grave_accent=toggle_quick_terminal"
      ];
    };
  };

  xdg.configFile = {
    "kitty/tab_bar.py".text = ''
      from kitty.fast_data_types import get_boss

      def draw_title(data):
          tab = get_boss().tab_for_id(data['tab'].tab_id)
          if tab:
              for window in tab:
                  status = window.user_vars.get("workmux_status", "")
                  if status:
                      return " " + status
          return ""
    '';

    "kitty/workmux_watcher.py".text = ''
      from kitty.boss import Boss
      from kitty.window import Window

      def on_focus_change(boss: Boss, window: Window, data: dict) -> None:
          if not data.get("focused"):
              return
          if window.user_vars.get("workmux_auto_clear") == "1":
              boss.call_remote_control(window, (
                  "set-user-vars", f"--match=id:{window.id}",
                  "workmux_status=", "workmux_auto_clear=",
              ))

      def on_set_user_var(boss: Boss, window: Window, data: dict) -> None:
          if data.get("key") == "workmux_status":
              tm = boss.os_window_map.get(window.os_window_id)
              if tm is not None:
                  tm.update_tab_bar_data()
                  tm.mark_tab_bar_dirty()
    '';
  };

  programs.kitty = {
    enable = true;
    settings = {
      # Fonts - Regular for normal, ExtraBold for bold to maximize contrast
      font_family = "Iosevka Nerd Font Mono";
      # Workmux kitty backend
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty-{kitty_pid}";

      font_size = if laptop then 14 else 20;
      bold_font_weight = 700;

      # Cursor customization
      cursor_shape = "block";
      cursor_beam_thickness = 1.5;
      cursor_underline_thickness = 2.0;
      cursor_stop_blinking_after = 15.0;

      # Mouse
      copy_on_select = true;

      # Window layout
      enabled_layouts = "splits,stack";

      # macOS specific
      macos_option_as_alt = true;
      macos_thicken_font = 0.0;

      tab_bar_style = "slant";
      tab_title_template = "{index}: {session_name + ' ' if session_name and session_name != 'default' else ''}{title}{custom}";
      watcher = "workmux_watcher.py";
    };

    # Use predefined Catppuccin Macchiato theme
    themeFile = "Catppuccin-Macchiato";

    # Key mappings
    keybindings = {
      "ctrl+shift+enter" = "launch --location=split --cwd=last_reported";
      "ctrl+tab" = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+l" = "next_layout";
      "f7>/" = "goto_session";
      "f7>l" = "goto_session langcache";
      "f7>n" = "goto_session nixos";
      "f7>-" = "goto_session -1";
      "ctrl+shift+space>1" = "goto_tab 1";
      "ctrl+shift+space>2" = "goto_tab 2";
      "ctrl+shift+space>3" = "goto_tab 3";
      "ctrl+shift+space>4" = "goto_tab 4";
      "ctrl+shift+space>5" = "goto_tab 5";
      "ctrl+shift+space>6" = "goto_tab 6";
      "ctrl+shift+space>7" = "goto_tab 7";
      "ctrl+shift+space>8" = "goto_tab 8";
      "ctrl+shift+space>9" = "goto_tab 9";
      "ctrl+shift+space>a" = "launch --cwd=last_reported zsh -l -i -c codex";
      "ctrl+shift+space>c" = "launch --cwd=last_reported zsh -l -i -c 'claude --permission-mode auto'";
      "ctrl+shift+space>w" =
        "launch --type=overlay-main --cwd=last_reported zsh -l -i -c 'workmux dashboard'";
    };
  };
}
