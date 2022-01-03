{ stdenv, fetchFromGitHub, SDL2, SDL2_ttf, SDL2_image }:

stdenv.mkDerivation rec {
  pname = "poptracker";
  version = "0.17.2";

  src = fetchFromGitHub {
    owner = "black-sliver";
    repo = "PopTracker";
    rev = "v${version}";
    sha256 = "1lfz4mwd25bcja2h9n8zr13virhs050mxy0fs3q4xagqc6c4ihww";
    fetchSubmodules = true;
  };

  buildInputs = [ SDL2 SDL2_ttf SDL2_image ];

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
