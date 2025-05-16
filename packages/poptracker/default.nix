{ stdenv, fetchFromGitHub, SDL2, SDL2_ttf, SDL2_image, xorg, openssl, zlib }:

stdenv.mkDerivation rec {
  pname = "poptracker";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "black-sliver";
    repo = "PopTracker";
    rev = "v${version}";
    sha256 = "sha256-uGzgkXOXmpByXewDuo0NieXHYT6fzaHqyfP60V5fMOY=";
    fetchSubmodules = true;
  };

  buildInputs = [ SDL2 SDL2_ttf SDL2_image xorg.libX11 openssl zlib ];

  buildFlags = [
    "CONF=RELEASE"
    "native"
  ];

  postPatch = ''
    substituteInPlace src/core/assets.cpp \
      --replace 'os_pathcat("assets", name)' 'os_pathcat("${placeholder "out"}/share/poptracker/assets", name)'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/linux-x86_64/poptracker $out/bin/poptracker

    mkdir -p $out/share/poptracker
    cp -r assets $out/share/poptracker/assets
  '';
}
