{ stdenv, makeWrapper, pkgs }:

stdenv.mkDerivation rec {
  name = "local-utils";
  src = ./bin;
  buildInputs = [ makeWrapper ];
  wrapperPath = with pkgs; stdenv.lib.makeBinPath [
    ffmpeg
    libnotify
    maim
    pass
    (python3.withPackages (p: with p; [
      requests
      beautifulsoup4
      lxml
    ]))
    rofi
    slop
    xdotool
    xorg.xprop
    xorg.xrandr
    xscreensaver
    xsecurelock
    zsh
  ];
  wrapperLibPath = with pkgs; stdenv.lib.makeLibraryPath [
    libudev
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp * $out/bin
  '';
  postFixup = ''
    find $out/bin -type f -executable | while read file; do
      patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 $file 2>/dev/null || true
      wrapProgram $file --prefix PATH : "${wrapperPath}" --prefix LD_LIBRARY_PATH : "${wrapperLibPath}"
    done
  '';
}
