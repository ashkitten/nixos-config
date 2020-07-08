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
    gnupg
    google-chrome
    gptfdisk
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
    lm_sensors
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
    pavucontrol
    pciutils
    python3Packages.binwalk
    qbittorrent
    ranger
    retroarchBare
    ripgrep
    rofi
    sc-controller
    ssb-patchwork
    steam
    steam-run
    syncplay
    tokei
    unrar
    unzip
    usbutils
    weechat
    wget
    wine
    winetricks
    wireshark
    wl-clipboard
    youtube-dl
    zip
    zstd
  ];
}
