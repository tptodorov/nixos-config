# Noctalia experiment (blackbox only)
#
# Noctalia is a Wayland desktop shell; Umbriel is its companion wlroots
# compositor. Both are pinned from the upstream v5 flakes -- the package in
# nixpkgs-unstable is not in our pinned nixpkgs.
#
# Scope of the experiment, deliberately narrow:
#   * Noctalia runs ONLY inside the Umbriel session. The existing niri + DMS
#     setup is untouched, because Noctalia and DankMaterialShell are both
#     Quickshell shells that each draw a bar and panels -- running both at once
#     fights over the same screen regions.
#   * The greeter is written up but left DISABLED. Enabling it replaces the
#     login screen, which cannot be tested without logging out, so it is a
#     deliberate separate step. See the commented block at the bottom.
#
# Log in by picking "Umbriel" at the GDM session menu; Noctalia autostarts
# there via programs.noctalia.systemd.enable.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  # Spec section 7.1: Primary copy/cut/paste are emitted as the conventional
  # alternate clipboard events, never as Ctrl+C/X/V.
  wtype = "${pkgs.wtype}/bin/wtype";

  umbrielPkg = inputs.umbriel.packages.${system}.default;
  noctaliaPkg = inputs.noctalia.packages.${system}.default;

  # Spec section 8.1. One snapshot of `umbriel windows --json`, filtered to
  # regular windows, then focus the selected id. Window ids are hex STRINGS,
  # and `workspace` is output-qualified ("HDMI-A-1:1"), so both are compared
  # as strings rather than numbers.
  #
  # Application order is the sorted unique app_id list, NOT snapshot order:
  # Umbriel returns windows MRU-first, so the focused app jumps to position 0
  # and "next after active" would oscillate between two applications forever.
  umbriel-cycle-window = pkgs.writeShellApplication {
    name = "umbriel-cycle-window";
    runtimeInputs = [
      umbrielPkg
      pkgs.jq
    ];
    text = ''
      mode=''${1:-}
      case "$mode" in
        application | same-application) ;;
        *)
          echo "usage: umbriel-cycle-window application|same-application" >&2
          exit 2
          ;;
      esac

      snapshot=$(umbriel windows --json)

      if [ "$mode" = same-application ]; then
        target=$(printf '%s' "$snapshot" | jq -r '
          map(select(.app_id != "" and .scratchpad == "")) as $w
          | ($w | map(select(.active)) | first) as $cur
          | if $cur == null then empty else
              ($w | map(select(.app_id == $cur.app_id and .workspace == $cur.workspace))
                  | sort_by(.id)) as $sib
              | if ($sib | length) < 2 then empty else
                  ((($sib | map(.id) | index($cur.id)) // -1) + 1) as $i
                  | $sib[$i % ($sib | length)] | .id
                end
            end')
      else
        target=$(printf '%s' "$snapshot" | jq -r '
          map(select(.app_id != "" and .scratchpad == "")) as $w
          | ($w | map(.app_id) | unique) as $apps
          | ($w | map(select(.active)) | first) as $cur
          | if $cur == null or ($apps | length) < 2 then empty else
              ((($apps | index($cur.app_id)) // -1) + 1) as $i
              | $apps[$i % ($apps | length)] as $next
              | ($w | map(select(.app_id == $next))
                   | (map(select(.focused)) + .) | first | .id)
            end')
      fi

      [ -n "$target" ] || exit 0
      umbriel msg "window-focus:$target"
    '';
  };

  # Spec section 8.2. User text is never passed through a shell: it is read
  # from noctalia dmenu, URL-encoded with jq @uri, and handed to xdg-open as a
  # single argument. jira.env is parsed, never sourced.
  macos-workflow = pkgs.writeShellApplication {
    name = "macos-workflow";
    runtimeInputs = [
      noctaliaPkg
      pkgs.jq
      pkgs.xdg-utils
      pkgs.libnotify
    ];
    text = ''
      notify() {
        notify-send "macos-workflow" "$1" || true
      }

      search() {
        query=$(noctalia dmenu < /dev/null) || exit 0
        [ -n "$query" ] || exit 0
        encoded=$(printf '%s' "$1$query" | jq -sRr @uri)
        xdg-open "https://www.google.com/search?q=$encoded"
      }

      case "''${1:-}" in
        define) search "define:" ;;
        google) search "" ;;
        jira)
          env_file="$HOME/.config/wtf/jira.env"
          if [ ! -f "$env_file" ]; then
            notify "missing $env_file"
            exit 1
          fi
          count=$(grep -c '^JIRA_URL=' "$env_file" || true)
          if [ "$count" != 1 ]; then
            notify "expected exactly one JIRA_URL= in jira.env, found $count"
            exit 1
          fi
          url=$(grep '^JIRA_URL=' "$env_file" | head -1 | cut -d= -f2-)
          url=''${url%\"}
          url=''${url#\"}
          case "$url" in
            http://* | https://*) ;;
            *)
              notify "JIRA_URL must be http(s)"
              exit 1
              ;;
          esac
          if printf '%s' "$url" | LC_ALL=C grep -q '[[:cntrl:]]'; then
            notify "JIRA_URL contains control characters"
            exit 1
          fi
          xdg-open "''${url%/}/secure/ManageFilters.jspa?search=Search"
          ;;
        *)
          echo "usage: macos-workflow define|jira|google" >&2
          exit 2
          ;;
      esac
    '';
  };

  # Spec section 7.4: application commands defined once.
  shortcutApps = {
    mail = "${pkgs.gtk3}/bin/gtk-launch notion-mail";
    calendar = "${pkgs.gtk3}/bin/gtk-launch notion-calendar";
    terminal = "${pkgs.wezterm}/bin/wezterm";
    browser = "${pkgs.brave}/bin/brave";
    files = "${pkgs.nautilus}/bin/nautilus";
    notes = "${pkgs.obsidian}/bin/obsidian";
  };
in
{
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.umbriel.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Upstream's binary cache. Their nixos docs warn against inputs.nixpkgs.follows
  # on these inputs precisely so these substitutions stay valid, so the flake
  # inputs intentionally keep their own nixpkgs.
  nix.settings = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${system}.default;
    # Starts the shell with the session. Scoped to umbriel-session.target
    # rather than the default graphical-session.target, which fires in EVERY
    # Wayland session -- that would start Noctalia alongside DMS under niri and
    # have the two shells fight over the same screen regions.
    systemd = {
      enable = true;
      target = "umbriel-session.target";
    };
    # Wires NetworkManager, bluetooth, upower and power-profiles-daemon, which
    # the wifi/bluetooth/battery widgets read from. Bluetooth and NetworkManager
    # are already on for this host; upower/power-profiles come from here.
    recommendedServices.enable = true;
  };

  # Caps Lock as Hyper (spec section 5.2).
  #
  # keyd remaps at the evdev layer, below the compositor, so Caps becomes a
  # hold-only Control+Alt+Shift+Super modifier in every session -- Umbriel,
  # niri and GNOME alike. Tapping it does nothing and must not toggle caps.
  #
  # Scoped to the Lofree Flow84 by id rather than "*": the machine also exposes
  # a "ydotoold virtual device" keyboard, and grabbing that would put keyd in
  # the path of Voxtype's own synthetic typing.
  services.keyd = {
    enable = true;
    keyboards.flow84 = {
      ids = [ "05ac:024f" ];
      settings.main.capslock = "layer(hyper)";
      extraConfig = ''
        [hyper:C-A-S-M]
      '';
    };
  };

  programs.umbriel = {
    enable = true;
    package = inputs.umbriel.packages.${system}.default;
  };

  # Umbriel's own config, kept here rather than in home/todor/modules so the
  # whole experiment stays in one blackbox-only file.
  home-manager.users.todor = {
    imports = [
      inputs.umbriel.homeModules.default
      inputs.noctalia.homeModules.default
    ];

    # Spec section 8: only the helper derivations go here; their runtime
    # inputs stay on the wrappers for closure correctness.
    home.packages = [
      umbriel-cycle-window
      macos-workflow
    ];

    programs.noctalia = {
      enable = true;
      package = inputs.noctalia.packages.${system}.default;
      # Seeds ~/.config/noctalia/config.toml, which is separate from the
      # runtime ~/.local/state/noctalia/settings.toml that Noctalia owns and
      # rewrites. Upstream states these stay overridable from the settings
      # menu, so pinning the theme here does not make the shell read-only.
      # Catppuccin matches the Catppuccin Macchiato already used by nixvim,
      # tmux, wezterm, ghostty, kitty and sway.
      settings = {
        # Spec section 7.2: MRU ordering for the Noctalia window switcher,
        # now reached by Primary+Tab.
        shell.window_switcher.mru = true;

        # Spec section 9. Only these two official plugins: notes backs the
        # Hyper+N "/nt" quick-add and its side panel, translator backs
        # Hyper+T "/tr". Their manifest defaults already match what the spec
        # wants (~/Documents/Notes with md, Google with target en), so no
        # plugin_settings overrides are declared -- the lock owns drift.
        plugins.enabled = [
          "noctalia/notes"
          "noctalia/translator"
        ];

        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        # Idle / screensaver.
        #
        # Noctalia seeds built-in Lock and Monitor-off behaviors but leaves
        # them DISABLED by default, so nothing ever triggered on this host --
        # the shell was tracking idle (ext_idle_notifier_v1, which Umbriel
        # implements) but had no enabled behavior to run.
        #
        # Timeouts mirror the AC values already used by DMS under niri
        # (home/todor/modules/dms.nix): monitors off at 5 min, lock at 10 min,
        # suspend at 30 min. blackbox is a desktop, so there is no battery set.
        idle = {
          behavior_order = [
            "screen-off"
            "lock"
            "suspend"
          ];
          behavior = {
            screen-off = {
              enabled = true;
              timeout = 300;
              action = "screen_off";
            };
            lock = {
              enabled = true;
              timeout = 600;
              action = "lock";
            };
            suspend = {
              enabled = true;
              timeout = 1800;
              action = "suspend";
              lock_before_suspend = true;
            };
          };
        };
      };
    };

    programs.umbriel = {
      enable = true;
      package = inputs.umbriel.packages.${system}.default;
      settings = {
        # Dell P2723QE, 27" 3840x2160. At scale 1 the desktop is unusably
        # small; 1.5 gives a 2560x1440 logical size, matching the fractional
        # scaling used for this panel elsewhere.
        # Spec section 5.3. mod_key is stated explicitly rather than relying
        # on Umbriel's default, and altwin:swap_alt_win is deliberately absent:
        # the Lofree Flow84 runs in Apple mode and already emits Command as
        # LEFTMETA, so the swap would invert the Primary and Option roles.
        general.mod_key = "Super";

        input.keyboard = {
          layout = "us,bg";
          variant = ",phonetic";
          repeat_rate = 50;
          repeat_delay = 250;
        };

        output."HDMI-A-1" = {
          mode = "3840x2160@60";
          scale = 1.5;
          # Spec section 7.2: keep workspaces dynamic but guarantee positions
          # 1-9 exist so Hyper+1..9 always has a target.
          min_workspaces = 9;
        };

        # Spec section 7. Defining [keybinds] REPLACES Umbriel's built-in
        # table, so every retained binding is explicit here.
        #
        # Role mapping on this host (verified 2026-09-18):
        #   Primary = Command key = logical Super = "Mod"
        #   Option  = Option key  = logical Alt
        #   Hyper   = Caps via keyd = Ctrl+Alt+Shift+Super, written literally
        #             as "Ctrl+Alt+Shift+Super" because Umbriel treats "Mod"
        #             and "Super" as distinct tokens.
        keybinds = {
          # --- 7.1 Edit -------------------------------------------------
          # Copy/cut/paste go through wtype's alternate clipboard chords.
          # Never inject Ctrl+C/X/V globally: in a terminal that is SIGINT.
          "Mod+C" = "spawn:${wtype} -M ctrl -k Insert -m ctrl";
          "Mod+X" = "spawn:${wtype} -M shift -k Delete -m shift";
          "Mod+V" = "spawn:${wtype} -M shift -k Insert -m shift";
          "Mod+Shift+V" = "spawn:noctalia msg panel-toggle clipboard";
          "Ctrl+Alt+Shift+Super+D" = "spawn:voxtype record toggle";
          "Ctrl+Alt+Shift+Super+L" = "keyboard-layout-next";
          # Physically Option+Command+Space, mirroring the macOS input-source
          # chord in docs/MACOS-SHORTCUTS.md. Kept alongside Hyper+L rather
          # than replacing it: Hyper+L is the shared cross-platform mnemonic.
          "Alt+Mod+Space" = "keyboard-layout-next";
          # Opens the Notes side panel directly (full-height, center_right)
          # rather than the launcher filtered to "/nt ", which still required
          # picking the Scratchpad entry by hand. The panel id comes from the
          # plugin manifest's [[panel]] block; Noctalia lists it as
          # "noctalia/notes:panel".
          "Ctrl+Alt+Shift+Super+N" = "spawn:noctalia msg panel-toggle \"noctalia/notes:panel\"";
          # Physically Option+Command+period, mirroring the macOS Raycast
          # Notes chord in docs/MACOS-SHORTCUTS.md.
          "Alt+Mod+period" = "spawn:noctalia msg panel-toggle \"noctalia/notes:panel\"";
          "Ctrl+Alt+Shift+Super+T" = "spawn:noctalia msg panel-toggle launcher \"/tr \"";
          "Ctrl+Alt+Shift+Super+W" = "spawn:${macos-workflow}/bin/macos-workflow define";
          "Ctrl+Alt+Shift+Super+S" = "spawn:${macos-workflow}/bin/macos-workflow google";
          "Ctrl+Alt+Shift+Super+J" = "spawn:${macos-workflow}/bin/macos-workflow jira";
          "Ctrl+Alt+Shift+Super+Slash" = "cheatsheet-toggle";
          # Physically Command+/, the easier chord for an F4 surface that is
          # reached for precisely when the Hyper mnemonics are forgotten.
          "Mod+Slash" = "cheatsheet-toggle";

          # --- 7.2 Navigate ---------------------------------------------
          # Linux-only divergence from the shared map: Primary+Tab is the
          # all-window switcher here, not application cycling. macOS reserves
          # Command+Tab for its own application switcher and will not yield it,
          # so the Mac keeps Raycast's Switch Windows on Option+Tab.
          "Mod+Tab" = {
            action = "spawn:noctalia msg window-switcher";
            repeat = false;
          };
          "Mod+grave" = "spawn:${umbriel-cycle-window}/bin/umbriel-cycle-window same-application";
          "Mod+Ctrl+Left" = "window-focus-left";
          "Mod+Ctrl+Right" = "window-focus-right";
          "Mod+Ctrl+Up" = "window-focus-up";
          "Mod+Ctrl+Down" = "window-focus-down";
          "Ctrl+Alt+Shift+Super+Left" = "workspace-previous";
          "Ctrl+Alt+Shift+Super+Right" = "workspace-next";
          "Ctrl+Alt+Shift+Super+1" = "workspace-switch:1";
          "Ctrl+Alt+Shift+Super+2" = "workspace-switch:2";
          "Ctrl+Alt+Shift+Super+3" = "workspace-switch:3";
          "Ctrl+Alt+Shift+Super+4" = "workspace-switch:4";
          "Ctrl+Alt+Shift+Super+5" = "workspace-switch:5";
          "Ctrl+Alt+Shift+Super+6" = "workspace-switch:6";
          "Ctrl+Alt+Shift+Super+7" = "workspace-switch:7";
          "Ctrl+Alt+Shift+Super+8" = "workspace-switch:8";
          "Ctrl+Alt+Shift+Super+9" = "workspace-switch:9";

          # --- 7.3 Arrange ----------------------------------------------
          # Preferred arrow family: all four chords verified on the Flow84.
          "Ctrl+Alt+Left" = "column-move-left";
          "Ctrl+Alt+Right" = "column-move-right";
          "Ctrl+Alt+Up" = "window-move-up";
          "Ctrl+Alt+Down" = "window-move-down";
          "Ctrl+Alt+Return" = "window-toggle-maximize-to-edges";
          # Moving a window between workspaces sits on Hyper+Up/Down rather
          # than the spec's Control+Option+Shift+Arrow: with Hyper on Caps,
          # Hyper+Left/Right is already workspace switching, so Up/Down is the
          # chord the hand actually reaches for and it was otherwise unused.
          "Ctrl+Alt+Shift+Super+Up" = "window-move-to-workspace-previous";
          "Ctrl+Alt+Shift+Super+Down" = "window-move-to-workspace-next";
          # Display movement keeps the spec chord: Hyper+Left/Right is taken
          # by workspace switching, so there is no Hyper pair free for it.
          "Ctrl+Alt+Shift+Left" = "window-move-to-output-previous";
          "Ctrl+Alt+Shift+Right" = "window-move-to-output-next";
          "Ctrl+Alt+F" = "window-toggle-fullscreen";
          "Ctrl+Alt+C" = "window-center";
          "Mod+M" = "window-move-to-scratchpad";

          # --- 7.4 Invoke -----------------------------------------------
          "Mod+Space" = "spawn:noctalia msg panel-toggle launcher";
          "Ctrl+Alt+Shift+Super+Return" = "spawn:${shortcutApps.terminal}";
          "Ctrl+Alt+Shift+Super+B" = "spawn:${shortcutApps.browser}";
          "Ctrl+Alt+Shift+Super+E" = "spawn:${shortcutApps.files}";
          "Ctrl+Alt+Shift+Super+O" = "spawn:${shortcutApps.notes}";
          "Ctrl+Alt+Shift+Super+M" = "spawn:${shortcutApps.mail}";
          "Ctrl+Alt+Shift+Super+C" = "spawn:${shortcutApps.calendar}";
          "Ctrl+Alt+Shift+Super+P" =
            "spawn:${pkgs.xdg-utils}/bin/xdg-open https://github.com/pulls";

          # --- 7.5 System -----------------------------------------------
          "Ctrl+Alt+Shift+Super+Escape" = {
            action = "shortcuts-inhibit-toggle";
            allow_when_inhibited = true;
            repeat = false;
          };
          "XF86AudioRaiseVolume" = {
            action = "spawn:noctalia msg volume-up";
            allow_when_locked = true;
          };
          "XF86AudioLowerVolume" = {
            action = "spawn:noctalia msg volume-down";
            allow_when_locked = true;
          };
          "XF86AudioMute" = {
            action = "spawn:noctalia msg volume-mute";
            repeat = false;
            allow_when_locked = true;
          };
          "XF86AudioMicMute" = {
            action = "spawn:noctalia msg mic-mute";
            repeat = false;
            allow_when_locked = true;
          };
          "XF86MonBrightnessUp" = {
            action = "spawn:noctalia msg brightness-up 10";
            allow_when_locked = true;
          };
          "XF86MonBrightnessDown" = {
            action = "spawn:noctalia msg brightness-down 10";
            allow_when_locked = true;
          };
        };
      };
    };
  };

  # X11 apps do work here. The Umbriel module passes enableXWayland = false to
  # wayland-session.nix, but that only skips NixOS's rootful XWayland: Umbriel
  # runs its own rootless one, with xwayland-satellite baked into the package's
  # PATH and general.xwayland defaulting to true. Verified by running xterm in a
  # headless Umbriel -- it came up on DISPLAY :2.

  # --- Greeter: ENABLED -------------------------------------------------
  #
  # noctalia-greeter replaces the login screen. Three conflicts had to be
  # resolved to make it actually take effect:
  #
  #  1. gnome.nix enables GDM and sets services.greetd.enable = lib.mkForce
  #     false. mkForce can only be overridden by another mkForce, hence the
  #     mkForce pair below.
  #  2. desktop.nix sets greetd's default_session.command to tuigreet at
  #     NORMAL priority, while the greeter module sets its own command with
  #     lib.mkDefault -- so tuigreet would win and the greeter would never be
  #     drawn. mkForce on the command settles it.
  #  3. GNOME stays selectable without extra work: the desktop-manager module
  #     registers pkgs.gnome-session.sessions in
  #     services.displayManager.sessionPackages itself, independently of GDM.
  #
  # Recovery, if the greeter ever fails to draw: switch to a TTY with
  # Ctrl+Alt+F2 and roll back with
  #   sudo nixos-rebuild switch --rollback
  # or pick an earlier generation in systemd-boot (10 are retained).
  services.displayManager.gdm.enable = lib.mkForce false;
  services.greetd.enable = lib.mkForce true;
  services.greetd.settings.default_session.command = lib.mkForce (
    "${inputs.noctalia-greeter.packages.${system}.default}/bin/noctalia-greeter-session"
  );

  services.displayManager.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.${system}.default;
    cursorTheme.package = pkgs.adwaita-icon-theme;
    settings = {
      session.default = "niri";
      user.default = "todor";
      appearance = {
        scheme = "Synced";
        theme_mode = "dark";
      };
      cursor.size = 24;
      keyboard.layout = "us";
    };
  };
}
