# Mac-style keyboard remapping using keyd
# This module provides Mac-like keyboard shortcuts on Linux systems
# Similar to kinto.sh functionality but using keyd which works well with NixOS
{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Enable keyd service
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # Make Caps Lock act as Control when held
            capslock = "overload(control, esc)";

            # Swap Alt and Super (Command) keys for Mac-like behavior
            # This makes the physical Command key act as Alt and vice versa
            leftalt = "leftmeta";
            leftmeta = "leftalt";
            rightalt = "rightmeta";
            rightmeta = "rightalt";
          };

          # Application remapping layer for GUI applications
          # This provides Mac-like shortcuts (Cmd+C, Cmd+V, etc.)
          "control:C" = {
            # Common shortcuts - use Super (which is now physical Alt) as modifier
            # Copy/Paste/Cut
            c = "C-c";  # Cmd+C -> Ctrl+C
            v = "C-v";  # Cmd+V -> Ctrl+V
            x = "C-x";  # Cmd+X -> Ctrl+X

            # Undo/Redo
            z = "C-z";  # Cmd+Z -> Ctrl+Z
            y = "C-y";  # Cmd+Y -> Ctrl+Y (redo in some apps)

            # Select all
            a = "C-a";  # Cmd+A -> Ctrl+A

            # Find
            f = "C-f";  # Cmd+F -> Ctrl+F

            # Save/Open/New
            s = "C-s";  # Cmd+S -> Ctrl+S
            o = "C-o";  # Cmd+O -> Ctrl+O
            n = "C-n";  # Cmd+N -> Ctrl+N

            # Window/Tab management
            w = "C-w";      # Cmd+W -> Ctrl+W (close tab/window)
            t = "C-t";      # Cmd+T -> Ctrl+T (new tab)
            tab = "A-tab";  # Cmd+Tab -> Alt+Tab (app switcher)

            # Browser shortcuts
            r = "C-r";        # Cmd+R -> Ctrl+R (refresh)
            l = "C-l";        # Cmd+L -> Ctrl+L (address bar)
            left = "A-left";  # Cmd+Left -> Alt+Left (browser back)
            right = "A-right"; # Cmd+Right -> Alt+Right (browser forward)

            # Text navigation (Mac-style)
            backspace = "C-backspace";  # Cmd+Backspace -> Ctrl+Backspace (delete word)

            # Quit application
            q = "A-f4";  # Cmd+Q -> Alt+F4
          };

          # Terminal application layer - restore standard terminal behavior
          # When in terminal, Ctrl should work as Ctrl, not as Cmd
          "alt:C" = {
            # In terminals, we want physical Ctrl to work as Ctrl
            # Since we swapped keys, physical Ctrl is now Alt
            # So we map Alt back to Ctrl in terminal contexts
            c = "C-c";  # Ctrl+C (interrupt)
            d = "C-d";  # Ctrl+D (EOF)
            z = "C-z";  # Ctrl+Z (suspend)
            l = "C-l";  # Ctrl+L (clear)
            r = "C-r";  # Ctrl+R (reverse search)
            a = "C-a";  # Ctrl+A (beginning of line)
            e = "C-e";  # Ctrl+E (end of line)
            k = "C-k";  # Ctrl+K (kill line)
            u = "C-u";  # Ctrl+U (kill line backwards)
            w = "C-w";  # Ctrl+W (delete word)
          };
        };

        # Per-application settings for terminal emulators
        extraConfig = ''
          # Terminal applications - use standard terminal shortcuts
          [alacritty:C]
          [kitty:C]
          [ghostty:C]
          [rio:C]
          [gnome-terminal:C]
          [konsole:C]
          [terminator:C]

          # For terminals, restore normal Ctrl behavior
          # (keyd will match application by window class)
        '';
      };
    };
  };

  # Palm rejection configuration for laptop keyboards
  # This prevents the virtual keyd keyboard from triggering palm rejection
  environment.etc."libinput/local-overrides.quirks" = lib.mkIf config.services.keyd.enable {
    text = ''
      [Serial Keyboards]
      MatchUdevType=keyboard
      MatchName=keyd virtual keyboard
      AttrKeyboardIntegration=internal
    '';
  };

  # Add keyd to system packages for manual configuration/testing
  environment.systemPackages = with pkgs; [
    keyd
  ];
}
