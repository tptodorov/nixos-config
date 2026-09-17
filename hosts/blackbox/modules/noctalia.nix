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

    programs.noctalia = {
      enable = true;
      package = inputs.noctalia.packages.${system}.default;
      # Seeds ~/.config/noctalia/config.toml, which is separate from the
      # runtime ~/.local/state/noctalia/settings.toml that Noctalia owns and
      # rewrites. Upstream states these stay overridable from the settings
      # menu, so pinning the theme here does not make the shell read-only.
      # Catppuccin matches the Catppuccin Macchiato already used by nixvim,
      # tmux, wezterm, ghostty, kitty and sway.
      settings.theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };

    programs.umbriel = {
      enable = true;
      package = inputs.umbriel.packages.${system}.default;
      settings = {
        # Dell P2723QE, 27" 3840x2160. At scale 1 the desktop is unusably
        # small; 1.5 gives a 2560x1440 logical size, matching the fractional
        # scaling used for this panel elsewhere.
        output."HDMI-A-1" = {
          mode = "3840x2160@60";
          scale = 1.5;
        };

        # Umbriel ships the cheatsheet-toggle action but binds no key to it by
        # default, so the keybind overlay was unreachable without the CLI.
        # Mod+slash matches the DMS keybind overlay under mangowc.
        #
        # NOTE: defining [keybinds] REPLACES the entire built-in set rather than
        # extending it, so the defaults that matter are restated here.
        keybinds = {
          "Mod+slash" = "cheatsheet-toggle";
          "Mod+Shift+slash" = "cheatsheet-toggle";

          # Restated defaults (see examples/config.toml in the umbriel repo)
          "Mod+Return" = "spawn:wezterm";
          "Mod" = "spawn:noctalia msg panel-toggle launcher";
          "Mod+Q" = "window-close";
          "Mod+Left" = "window-focus-left";
          "Mod+Down" = "window-focus-down";
          "Mod+Up" = "window-focus-up";
          "Mod+Right" = "window-focus-right";
          "Mod+H" = "window-focus-left";
          "Mod+J" = "window-focus-down";
          "Mod+K" = "window-focus-up";
          "Mod+L" = "window-focus-right";
          "Mod+Shift+Left" = "column-move-left";
          "Mod+Shift+Down" = "window-move-down";
          "Mod+Shift+Up" = "window-move-up";
          "Mod+Shift+Right" = "column-move-right";
          "Mod+T" = "window-toggle-floating";
          "Mod+P" = "window-toggle-pinned";
          "Mod+M" = "window-toggle-maximize-to-edges";
          "Mod+F" = "window-toggle-fullscreen";
          "Mod+Ctrl+F" = "window-toggle-maximize";
          "Mod+O" = "overview-toggle";
          "Mod+Escape" = "session-quit";
          "Mod+F1" = "window-focus-next";
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
