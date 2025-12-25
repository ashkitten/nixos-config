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

    (protonmail-bridge.overrideAttrs (old: {
      postPatch = ''
        substituteInPlace pkg/keychain/helper_linux.go \
          --replace-fail 'isUsable(newPassHelper(""))' 'false' \
          --replace-fail 'isUsable(newSecretServiceHelper(""))' 'false'
      '';
    }))

    anytype
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
    # cura
    dconf
    direnv
    dolphin-emu
    easyeffects
    eww
    eza
    feh
    ffmpeg-full
    file
    ghidra
    gimp
    gist
    github-cli
    adwaita-icon-theme
    gnupg
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
    kdePackages.kdenlive
    kdePackages.neochat
    kdePackages.elisa
    krita
    libnotify
    libreoffice
    lm_sensors
    lsof
    lsp-plugins
    ltunify
    lutris
    manix
    mgba
    mpv
    mumble
    nextcloud-client
    nheko
    nix-index
    nix-output-monitor
    nix-prefetch-scripts
    nix-top
    obsidian
    # opencomposite
    # opencomposite-helper
    osu-lazer
    pavucontrol
    pciutils
    prismlauncher
    protontricks
    binwalk
    qbittorrent
    qFlipper
    qjackctl
    qsynth
    r2modman
    ranger
    remmina
    retroarch-bare
    ripgrep
    rnnoise-plugin
    rsync
    signal-desktop
    slurp
    socat
    space-station-14-launcher
    speedcrunch
    steam-run
    strace
    synadm
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
    winePackages.waylandFull
    winetricks
    wireshark
    wl-clipboard
    xp-pen-g430-driver
    yt-dlp
    zip
    zstd
  ];
}
