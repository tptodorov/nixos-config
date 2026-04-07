{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Media and entertainment applications
  home.packages = with pkgs; [
    vlc # Video player
    transmission_4-gtk # Torrent client with GTK interface
    (lib.lowPrio sox) # Sound processing tool (lowPrio to avoid conflict with gotools' play binary)
    openai-whisper # OpenAI Whisper speech recognition
  ];

  programs = {
    spotify-player.enable = true;
  };

  # XDG MIME associations for magnet links
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/magnet" = [ "transmission-gtk.desktop" ];
  };
}
