# Host adapter for the shared Noctalia/Umbriel desktop profile.
{
  ...
}:
{
  imports = [
    ../../../modules/profiles/noctalia.nix
  ];

  services.keyd.keyboards = {
    # Caps Lock as Hyper on the built-in Lenovo keyboard.
    blade-internal = {
      ids = [ "0001:0001" ];
      settings.main.capslock = "layer(hyper)";
      extraConfig = ''
        [hyper:C-A-S-M]
      '';
    };

    # Keep the external Flow84 behavior identical to blackbox when paired with
    # blade. Scope by id rather than "*" so keyd does not grab ydotoold's
    # virtual keyboard.
    flow84 = {
      ids = [ "05ac:024f" ];
      settings.main.capslock = "layer(hyper)";
      extraConfig = ''
        [hyper:C-A-S-M]
      '';
    };
  };

  home-manager.users.todor.programs.umbriel.settings.output."eDP-1" = {
    mode = "2880x1800";
    scale = 2.0;
    min_workspaces = 9;
  };
}
