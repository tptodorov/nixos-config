# Host adapter for the shared Noctalia/Umbriel desktop profile.
{
  ...
}:
{
  imports = [
    ../../../modules/profiles/noctalia.nix
  ];

  # Caps Lock as Hyper on the Lofree Flow84. Scope by id rather than "*" so
  # keyd does not grab ydotoold's virtual keyboard.
  services.keyd.keyboards.flow84 = {
    ids = [ "05ac:024f" ];
    settings.main.capslock = "layer(hyper)";
    extraConfig = ''
      [hyper:C-A-S-M]
    '';
  };

  home-manager.users.todor.programs.umbriel.settings.output."HDMI-A-1" = {
    mode = "3840x2160@60";
    scale = 1.5;
    # Keep workspaces dynamic but guarantee positions 1-9 exist so Hyper+1..9
    # always has a target.
    min_workspaces = 9;
  };
}
