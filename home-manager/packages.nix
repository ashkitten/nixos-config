{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (callPackage ./local-utils {})
    #(callPackage ../packages/BeatSyncConsole {})
    #(callPackage ../packages/g933-utils {})
    # (callPackage ../packages/imgoverlay {})
    (callPackage ../packages/poptracker {})
    obs-studio-plugins.obs-vkcapture

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

    (dwarf-fortress-packages.dwarf-fortress-full.override {
      theme = "spacefox";
    })

    (xivlauncher.override { useSteamRun = false; })
    
    (steam.override {
      extraLibraries = pkgs: with pkgs; [
        gnutls

        # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    })

    arduino
    aria2
    atool
    # beataroni
    bind
    blender-hip
    calc
    calibre
    carla
    chrysalis
    cura
    dconf
    direnv
    dolphinEmuMaster
    easyeffects
    eww-wayland
    eza
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
    hyprpaper
    imagemagick
    inetutils
    inkscape
    jellyfin-media-player
    jq
    kdenlive
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
    qsynth
    ranger
    remmina
    retroarchBare
    ripgrep
    rnix-lsp
    rnix-lsp
    rnnoise-plugin
    rsync
    slurp
    socat
    space-station-14-launcher
    steam-run
    strace
    syncplay
    tenacity
    thunderbird
    tokei
    unrar
    unzip
    usbutils
    vscode
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
