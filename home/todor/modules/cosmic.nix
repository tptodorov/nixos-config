{
  pkgs,
  ...
}:
{
  # COSMIC Desktop Environment configuration using cosmic-manager
  # Universal clipboard keybindings (Omarchy-style)

  home.packages = with pkgs; [
    wtype # For simulating keyboard input
  ];

  # Enable cosmic-manager
  wayland.desktopManager.cosmic.enable = true;

  # COSMIC keybinding configuration via cosmic-manager
  wayland.desktopManager.cosmic.shortcuts = [
    # Super+Enter -> Terminal
    {
      key = "Super+Return";
      action = {
        __type = "enum";
        variant = "Spawn";
        value = [ "${pkgs.kitty}/bin/kitty" ];
      };
    }
    # Super+Shift+V -> Clipboard history
    {
      description = {
        __type = "optional";
        value = "Clipboard History";
      };
      key = "Super+SHIFT+V";
      action = {
        __type = "enum";
        variant = "Spawn";
        value = [
          "${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel -d | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
        ];
      };
    }
  ];
}
