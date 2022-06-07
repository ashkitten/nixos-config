{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (callPackage ./local-utils {})
    #(callPackage ../packages/BeatSyncConsole {})
    #(callPackage ../packages/Beataroni {})
    #(callPackage ../packages/g933-utils {})
    (callPackage ../packages/imgoverlay {})
    (callPackage ../packages/poptracker {})
    obs-studio-plugins.obs-vkcapture

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

    (dwarf-fortress-packages.dwarf-fortress-full.override {
      theme = "spacefox";
    })

    (xivlauncher.override { useSteamRun = false; })

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
    dconf
    direnv
    dolphinEmuMaster
    easyeffects
    exa
    feh
    ffmpeg-full
    file
    firefox
    gimp
    gist
    gnome3.adwaita-icon-theme
    gnupg
    google-chrome
    gptfdisk
    helix
    hexd
    htop
    hwinfo
    imagemagick
    inetutils
    inkscape
    jellyfin-media-player
    jq
    kdenlive
    kitty
    krita
    libnotify
    lm_sensors
    lsof
    lsp-plugins
    ltunify
    lutris
    matrix-synapse-tools.synadm
    mgba
    mpv
    mumble
    nextcloud-client
    nix-index
    nix-prefetch-scripts
    nix-top
    obsidian
    pavucontrol
    pciutils
    pentablet-driver
    polymc
    python3Packages.binwalk
    qbittorrent
    qflipper
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
    thunderbird
    tokei
    unrar
    unzip
    usbutils
    warzone2100
    weechat
    wget
    wine-staging
    winetricks
    wireshark
    wl-clipboard
    youtube-dl
    zip
    zstd
  ];
}
