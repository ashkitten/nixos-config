{ pkgs, ... }:

{
  imports = [
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    (callPackage ./packages/local-utils {})
    (callPackage ./packages/g933-utils {})

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

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
    lollypop
    lsof
    ltunify
    mgba
    mpv
    mumble
    nextcloud-client
    nix-index
    nix-prefetch-scripts
    nix-top
    p7zip
    pavucontrol
    pciutils
    python3Packages.binwalk
    qbittorrent
    ranger
    retroarchBare
    ripgrep
    rofi
    sc-controller
    steam
    steam-run
    syncplay
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
    wl-clipboard
    zip
  ];
}
