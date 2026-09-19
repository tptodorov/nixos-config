# Catppuccin Macchiato for every Home Manager program that has a catppuccin/nix
# port. Ports only apply to programs enabled via programs.<name>.enable.
{ inputs, ... }:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    # Same accent as the Noctalia palette in modules/profiles/noctalia.nix.
    accent = "peach";

    # The GTK theme port is archived upstream; only a Papirus icon port is
    # left, and it would swap the icon theme of every GTK app.
    gtk.icon.enable = false;
  };
}
