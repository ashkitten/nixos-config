{ stdenv, fetchFromGitHub, cmake, qt5, minizip }:

stdenv.mkDerivation {
  name = "qbeat";

  src = fetchFromGitHub {
    owner = "geefr";
    repo = "beatsaber-linux-goodies";
    rev = "a82ac3694ef2addb9f4c133a28ead9fac6a0b156";
    sha256 = "15ybc9phxca9y5v25dpx4mdhr91v02gbqsspvjf65dycj67b2vyz";
  };

  cmakeDir = "../QBeat";

  buildInputs = [
    cmake
    qt5.wrapQtAppsHook

    qt5.qtbase
    qt5.qtdeclarative
    minizip
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp QBeat $out/bin
    cp ../scripts/* $out/bin/
  '';
}
