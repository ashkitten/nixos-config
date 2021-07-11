{ pkgs, ... }:

{
  imports = [
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    (callPackage ./local-utils {})
    (callPackage ../packages/BeatSyncConsole {})
    #(callPackage ../packages/Beataroni {})
    (callPackage ../packages/ffmt {})
    #(callPackage ../packages/g933-utils {})
    (callPackage ../packages/imgoverlay {})

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

    (dwarf-fortress-packages.dwarf-fortress-full.override {
      theme = "spacefox";
    })

    arduino
    aria2
    atool
    audacity
    bind
    blender
    calc
    calibre
    carla
    cura
    direnv
    dolphinEmuMaster
    exa
    feh
    ffmpeg-full
    file
    firefox
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
    jellyfin-media-player
    jq
    kitty
    krita
    libnotify
    lm_sensors
    lsof
    ltunify
    lutris
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
    qjackctl
    ranger
    retroarchBare
    ripgrep
    rnnoise-plugin
    rsync
    slurp
    ssb-patchwork
    steam
    steam-run
    strace
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
