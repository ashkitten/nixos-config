{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (callPackage ./local-utils {})
    #(callPackage ../packages/BeatSyncConsole {})
    #(callPackage ../packages/g933-utils {})
    (callPackage ../packages/imgoverlay {})
    (callPackage ../packages/poptracker {})
    obs-studio-plugins.obs-vkcapture

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

    (dwarf-fortress-packages.dwarf-fortress-full.override {
      theme = "spacefox";
    })

    (xivlauncher.override { useSteamRun = false; })
    
    (steam.override { extraLibraries = pkgs: with pkgs; [ gnutls ]; })

    arduino
    aria2
    atool
    # beataroni
    bind
    blender
    calc
    calibre
    carla
    chrysalis
    cura
    dconf
    direnv
    dolphinEmuMaster
    easyeffects
    exa
    feh
    ffmpeg-full
    file
    gimp
    gist
    github-cli
    gnome.adwaita-icon-theme
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
    manix
    matrix-synapse-tools.synadm
    mgba
    mpv
    mumble
    nextcloud-client
    nix-index
    nix-prefetch-scripts
    nix-top
    obsidian
    osu-lazer
    pavucontrol
    pciutils
    pentablet-driver
    prismlauncher
    python3Packages.binwalk
    qbittorrent
    qflipper
    qjackctl
    ranger
    retroarchBare
    ripgrep
    rnix-lsp
    rnix-lsp
    rnnoise-plugin
    rsync
    slurp
    ssb-patchwork
    steam-run
    strace
    syncplay
    tenacity
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
