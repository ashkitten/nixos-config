{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (callPackage ./local-utils {})
    obs-studio-plugins.obs-vkcapture

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

    (xivlauncher.override { useSteamRun = false; })

    (protonmail-bridge.overrideAttrs (old: {
      postPatch = ''
        substituteInPlace pkg/keychain/helper_linux.go \
          --replace-fail 'isUsable(newPassHelper(""))' 'false' \
          --replace-fail 'isUsable(newSecretServiceHelper(""))' 'false'
      '';
    }))

    anytype
    aria2
    atool
    bind
    blender
    calc
    calibre
    carla
    chrysalis
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
    steam
    steam-run
    strace
    synadm
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
    yt-dlp
    zip
    zstd
  ];
}
