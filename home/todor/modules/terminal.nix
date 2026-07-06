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

    config.font = wezterm.font { family = "Iosevka NFM" }
    config.font_size = ${if laptop then "14" else "20"}

    config.color_scheme = "Catppuccin Macchiato"

    config.default_prog = { "zsh" }
    config.enable_wayland = true
    config.window_close_confirmation = "NeverPrompt"
    config.window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    }
    config.cursor_blink_rate = 0
    config.default_cursor_style = "SteadyBlock"
    config.hide_mouse_cursor_when_typing = true
    config.scrollback_lines = 10000
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false
    config.window_decorations = "RESIZE"
    config.use_fancy_tab_bar = false
    config.tab_bar_at_bottom = true
    config.tab_max_width = 64
    config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 1000 }

    local split_right = act.SplitHorizontal({ domain = "CurrentPaneDomain" })
    local split_down = act.SplitVertical({ domain = "CurrentPaneDomain" })

    wezterm.on("format-tab-title", function(tab)
      local title = tab.active_pane.title
      if title == nil or title == "" then
        title = "zsh"
      end
      return " " .. wezterm.mux.get_active_workspace() .. " " .. title .. " "
    end)

    config.keys = {
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
          command = { args = { "zsh", "-l", "-i", "-c", "claude" },},
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

      tab_bar_style = "powerline";
      tab_title_template = "{index}: {session_name} {title}{custom}";
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
      "ctrl+shift+space>c" = "launch --cwd=last_reported zsh -l -i -c claude";
      "ctrl+shift+space>w" =
        "launch --type=overlay-main --cwd=last_reported zsh -l -i -c 'workmux dashboard'";
    };
  };
}
