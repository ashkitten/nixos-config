pkgs: with pkgs; [
  (callPackage ./packages/local-utils {})
  (callPackage ./packages/roccat-tools {})
  (callPackage ./packages/g933-utils {})

  (import ./vscode.nix pkgs)
  (pass.withExtensions (ext: with ext; [ pass-otp ]))

  arc-theme
  arduino
  aria2
  atool
  audacity
  bind
  blender
  calc
  calibre
  direnv
  dolphinEmuMaster
  exa
  feh
  ffmpeg-full
  file
  firefox-bin
  gist
  glimpse
  gnome3.dconf
  gnome3.defaultIconTheme
  gnumake
  gnupg
  google-chrome
  hexd
  htop
  hwinfo
  imagemagick
  inetutils
  inkscape
  jq
  kitty
  krita
  libnotify
  lsof
  ltunify
  mgba
  mpv
  nextcloud-client
  nix-index
  nix-prefetch-scripts
  nix-top
  numix-icon-theme
  obs-studio
  p7zip
  pavucontrol
  pciutils
  pulseeffects
  python3Packages.binwalk
  qbittorrent
  ranger
  retroarchBare
  ripgrep
  rofi
  sc-controller
  steam
  steam-run
  tokei
  toot
  unrar
  unzip
  usbutils
  weechat
  wget
  wine
  winetricks
  wireshark
  xclip
  xdotool
  xorg.xbacklight
  xorg.xev
  zip
]
