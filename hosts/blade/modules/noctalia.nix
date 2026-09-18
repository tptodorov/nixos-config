# Noctalia/Umbriel desktop setup for blade.
#
# Reuse blackbox's WM and shortcut map intentionally: the goal is for blade to
# feel the same at the keyboard. The local settings below only add blade's
# built-in keyboard and internal display.
{
  ...
}:
{
  imports = [
    ../../blackbox/modules/noctalia.nix
  ];

  # Caps Lock as Hyper on the built-in Lenovo keyboard. Keep the Flow84 mapping
  # from the imported blackbox module too, so the external keyboard behaves the
  # same when paired with blade.
  services.keyd.keyboards.blade-internal = {
    ids = [ "0001:0001" ];
    settings.main.capslock = "layer(hyper)";
    extraConfig = ''
      [hyper:C-A-S-M]
    '';
  };

  home-manager.users.todor.programs.umbriel.settings.output."eDP-1" = {
    mode = "2880x1800";
    scale = 2.0;
    min_workspaces = 9;
  };
}
