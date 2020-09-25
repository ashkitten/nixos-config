{ pkgs, ... }:

{
  imports = [
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    (callPackage ./local-utils {})
    (callPackage ../packages/BeatSyncConsole {})
    (callPackage ../packages/QBeat { qt5 = qt514; })
    (callPackage ../packages/ffmt {})
    (callPackage ../packages/g933-utils {})
    (callPackage ../packages/imgoverlay {})

    (pass-wayland.withExtensions (ext: with ext; [ pass-otp ]))

    (let
      firefox-bin-patched = firefox-bin-unwrapped.overrideAttrs (old: {
        postFixup = ''
          sed -i 's/reserved="true"/               /g' $out/lib/firefox-bin-*/browser/omni.ja
        '';
      });
    in
      wrapFirefox firefox-bin-patched {
        browserName = "firefox";
        pname = "firefox-bin-patched";
        desktopName = "Firefox";
      }
    )

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
    prusa-slicer
    python3Packages.binwalk
    qbittorrent
    ranger
    retroarchBare
    ripgrep
    rofi
    rsync
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
