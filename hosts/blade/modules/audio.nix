{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  pythonWithDolbyDeps = pkgs.python3.withPackages (
    ps: with ps; [
      argcomplete
      numpy
      rich
      rich-argparse
      scipy
    ]
  );

  speakerTuningToEasyEffects = pkgs.stdenvNoCC.mkDerivation {
    pname = "speaker-tuning-to-easyeffects";
    version = "2026.08";

    src = inputs.speaker-tuning-to-easyeffects;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      app_dir="$out/share/speaker-tuning-to-easyeffects"
      mkdir -p "$app_dir" "$out/bin"
      cp -R . "$app_dir"

      for script in dolby_to_easyeffects.py dolby_to_pipewire.py ee_to_pipewire.py; do
        bin_name="''${script%.py}"
        makeWrapper ${pythonWithDolbyDeps}/bin/python3 "$out/bin/$bin_name" \
          --add-flags "$app_dir/$script" \
          --prefix PATH : ${
            lib.makeBinPath [
              pkgs.alsa-utils
              pkgs.coreutils
              pkgs.easyeffects
              pkgs.findutils
              pkgs.gnugrep
              pkgs.gnused
              pkgs.innoextract
              pkgs.lilv
              pkgs.lv2
              pkgs.pciutils
              pkgs.pipewire
              pkgs.procps
              pkgs.usbutils
            ]
          }
      done

      runHook postInstall
    '';
  };

  lenovoAudioDriver = pkgs.fetchurl {
    url = "https://download.lenovo.com/consumer/mobiles/wus5030fxfafvug0.exe";
    hash = "sha256-gnL9ynqAu5YmpfuP0DRfrvzpcoHl0RiPHU/wFTvoHi0=";
  };

  speakerSink = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";

  bladeDolbyPipewireFilter = pkgs.stdenvNoCC.mkDerivation {
    pname = "blade-dolby-pipewire-filter";
    version = "2025-12-04";

    src = lenovoAudioDriver;
    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.innoextract
      speakerTuningToEasyEffects
    ];

    LV2_PATH = lib.makeSearchPath "lib/lv2" [
      pkgs.calf
      pkgs.lsp-plugins
      pkgs.mda_lv2
      pkgs.zam-plugins
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p extracted "$out"
      innoextract -q -d extracted "$src"

      xml='extracted/code$GetExtractPath$/3rdparty/Dolby/ext_lenovo_AIO_rtk_22h2_24h2_v10.719.546.26/DEV_0287_SUBSYS_17AA3914_PCI_SUBSYS_384317AA.xml'
      HOME="$TMPDIR" XDG_CONFIG_HOME="$TMPDIR/.config" \
        dolby_to_pipewire \
          --variant balanced \
          --enable autogain \
          --target-sink "${speakerSink}" \
          --output-dir "$out" \
          --no-activate \
          "$xml"

      runHook postInstall
    '';
  };

  bladeSpeakerTuning = pkgs.writeShellApplication {
    name = "blade-speaker-tuning";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.easyeffects
      pkgs.innoextract
      pkgs.pipewire
      speakerTuningToEasyEffects
    ];

    text = ''
      set -euo pipefail

      usage() {
        cat <<'EOF'
      Usage:
        blade-speaker-tuning pipewire [DOLBY_XML_OR_DRIVER_DIR] [extra args...]
        blade-speaker-tuning easyeffects [DOLBY_XML_OR_DRIVER_DIR] [extra args...]
        blade-speaker-tuning doctor
        blade-speaker-tuning speaker-info

      Defaults:
        pipewire     Install an active PipeWire filter-chain with balanced voicing and autogain.
        easyeffects  Generate EasyEffects presets and autoload the balanced preset with autogain.

      If no XML or driver directory is passed, the converter auto-detects mounted Windows
      partitions and extracted Lenovo driver trees in the current directory.
      EOF
      }

      mode="''${1:-pipewire}"
      if [ "$#" -gt 0 ]; then
        shift
      fi

      case "$mode" in
        pipewire)
          exec dolby_to_pipewire --variant balanced --enable autogain "$@"
          ;;
        easyeffects)
          exec dolby_to_easyeffects --autoload --enable autogain "$@"
          ;;
        doctor)
          exec dolby_to_pipewire --doctor
          ;;
        speaker-info)
          exec dolby_to_easyeffects --speaker-info
          ;;
        help|-h|--help)
          usage
          ;;
        *)
          usage >&2
          exit 64
          ;;
      esac
    '';
  };
in
{
  # This machine uses the SOF HDA DSP path; keep the SOF blobs explicit so the
  # internal speakers do not depend on incidental firmware closure contents.
  hardware.firmware = [ pkgs.sof-firmware ];

  services.pipewire.extraLv2Packages = [
    pkgs.calf
    pkgs.lsp-plugins
    pkgs.mda_lv2
    pkgs.zam-plugins
  ];

  home-manager.users.todor.xdg.configFile = {
    "pipewire/pipewire.conf.d/Dolby_Balanced.conf".source =
      "${bladeDolbyPipewireFilter}/Dolby_Balanced.conf";
    "pipewire/pipewire.conf.d/Dolby_Balanced.irs".source =
      "${bladeDolbyPipewireFilter}/Dolby_Balanced.irs";
  };

  environment.systemPackages = [
    bladeSpeakerTuning
    pkgs.alsa-utils
    pkgs.calf
    pkgs.easyeffects
    pkgs.helvum
    pkgs.innoextract
    pkgs.lilv
    pkgs.lsp-plugins
    pkgs.lv2
    pkgs.mda_lv2
    pkgs.pavucontrol
    pkgs.pwvucontrol
    pkgs.zam-plugins
    speakerTuningToEasyEffects
  ];
}
