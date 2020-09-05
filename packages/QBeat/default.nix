{ stdenv, fetchFromGitHub, cmake, qt5, minizip }:

stdenv.mkDerivation rec {
  pname = "qbeat";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "geefr";
    repo = "beatsaber-linux-goodies";
    rev = version;
    sha256 = "0asw03r82ws1ngmjz9fa2da6mmpq0hvw738cin6c60k2mjlya6i4";
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
