{ stdenv, lib, fetchzip, xxd, freetype }:

let
  font = fetchzip {
    url = "https://www.fonts101.com/download/74940/Bad_Handwriting/5E7CEC578B6F17A289AC19C0E364855F";
    sha256 = "sha256-f7vRJYVtrkbxwZrBzRG2pWRsWMSGRlwWXFaa3vUlzNo=";
    extension = "zip";
    stripRoot = false;
  };
in
  stdenv.mkDerivation {
    pname = "crimes";
    version = "1.0";

    src = lib.cleanSource ./.;

    buildInputs = [ xxd freetype ];

    buildPhase = ''
      cp "${font}/Bad Handwriting.ttf" font
      xxd -i font > font.h
      cc -fPIC -shared -ldl -lfreetype crimes.c -o crimes.so
    '';

    installPhase = ''
      install -D crimes.so $out/lib/crimes.so
    '';
  }
