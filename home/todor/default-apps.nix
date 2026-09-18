{ pkgs }:
{
  browser = "${pkgs.brave}/bin/brave";
  browserDesktop = "brave-browser.desktop";

  terminal = "${pkgs.ghostty}/bin/ghostty";
  terminalName = "ghostty";

  files = "${pkgs.nautilus}/bin/nautilus";
  filesName = "nautilus";
  filesDesktop = "org.gnome.Nautilus.desktop";

  editor = "nvim";
  editorDesktops = [
    "Helix.desktop"
    "code.desktop"
    "code-insiders.desktop"
  ];
  notesDesktop = "obsidian.desktop";
}
