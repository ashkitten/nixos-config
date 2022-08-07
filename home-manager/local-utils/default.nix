{ stdenv, lib, makeWrapper, pkgs }:

stdenv.mkDerivation rec {
  name = "local-utils";
  src = ./bin;
  buildInputs = [ makeWrapper ];
  wrapperPath = with pkgs; lib.makeBinPath [
    ffmpeg
    grim
    libnotify
    pass-wayland
    python3
    rofi
    slurp
    wl-clipboard
    xscreensaver
    xsecurelock
    zsh
  ];
  wrapperLibPath = with pkgs; lib.makeLibraryPath [
    udev
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp * $out/bin
  '';
  postFixup = ''
    find $out/bin -type f -executable | while read file; do
      patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $file 2>/dev/null || true
      wrapProgram $file --prefix PATH : "${wrapperPath}" --prefix LD_LIBRARY_PATH : "${wrapperLibPath}"
    done
  '';
}
