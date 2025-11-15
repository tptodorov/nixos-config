{ stdenv
, lib
, fetchFromGitHub
, kernel
, kmod
}:

stdenv.mkDerivation rec {
  pname = "snd-hda-macbookpro";
  version = "unstable-2024-12-09";

  src = fetchFromGitHub {
    owner = "davidjo";
    repo = "snd_hda_macbookpro";
    rev = "5c7a1c24459aa93e67f293e695914affe057035a";  # Latest commit from master
    hash = "sha256-mLhY57j7taBROWCiuH2Oj2o9YxmpAenMs9aHwe0086M=";
  };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ kmod ];

  makeFlags = kernel.makeFlags ++ [
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    runHook preBuild
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) INSTALL_MOD_PATH=$out modules_install
    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux kernel driver for MacBook Pro audio (Cirrus Logic CS8409 HDA)";
    homepage = "https://github.com/davidjo/snd_hda_macbookpro";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
