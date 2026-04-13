{
  lib,
  pkgs,
  ...
}:
let
  mmtTool = pkgs.buildGoModule rec {
    pname = "mmt";
    version = "2.0";

    src = pkgs.fetchFromGitHub {
      owner = "KonradIT";
      repo = "mmt";
      rev = "v${version}";
      hash = "sha256-Se5mVj2+QWggaoScfLTLb3sRCI/mDAWYZX/5WTn9syQ=";
    };

    vendorHash = "sha256-obrRLICBpI8dxojaHm3SY+B2sBSTbq/dteUvTNTtwpE=";
    doCheck = false;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      wrapProgram "$out/bin/mmt" \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.ffmpeg
            pkgs.android-tools
          ]
        }
    '';
  };
in
{
  # Media and entertainment applications
  home.packages = with pkgs; [
    vlc # Video player
    transmission_4-gtk # Torrent client with GTK interface
    (lib.lowPrio sox) # Sound processing tool (lowPrio to avoid conflict with gotools' play binary)
    openai-whisper # OpenAI Whisper speech recognition
    mmtTool # Media management tool for GoPro and other action cameras
  ];

  programs = {
    spotify-player.enable = true;
  };

  # XDG MIME associations for magnet links
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/magnet" = [ "transmission-gtk.desktop" ];
  };
}
