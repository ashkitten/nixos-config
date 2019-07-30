{ pkgs, ... }:

let
  nixos = import <nixpkgs/nixos> {};
in {
  home = {
    packages = with pkgs; [
      (callPackage ./local-utils {})

      (pass.withExtensions (ext: with ext; [ pass-otp ]))
      arc-theme
      arduino
      aria2
      atool
      audacity
      bind
      blender
      calc
      direnv
      dolphinEmuMaster
      exa
      feh
      ffmpeg-full
      file
      firefox
      gist
      gnome3.dconf
      gnome3.defaultIconTheme
      gnumake
      gnupg
      google-chrome
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
      toot
      unrar
      unzip
      usbutils
      vscode
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
    ];
  };

  programs = {
    browserpass.enable = true;

    git = {
      enable = true;
      userName = "ash lea";
      userEmail = "ashlea@protonmail.com";
      aliases = {
        l = "log --abbrev-commit --pretty=oneline -n 10";
      };
      extraConfig = ''
          [transfer]
            fsckobjects = true
          [core]
            excludesfile = ~/.gitignore
            autocrlf = input
          [push]
            default = simple
      '';
    };

    neovim = {
      enable = true;
      withPython = true;
      withPython3 = true;
    };

    tmux = {
      enable = true;
      extraConfig = builtins.readFile ./dotfiles/.tmux.conf;
    };
  };

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          follow = "keyboard";
          geometry = "800x5-20+20";
          shrink = "yes";
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = "#d70a53";
          font = "Source Code Pro 10";
          markup = "no";
          format = "<b>%s</b> <i>(%a)</i> <b>%p</b>\\n%b";
          word_wrap = "yes";
          icon_position = "left";
          max_icon_size = 50;
          history_length = 100;
          dmenu = "rofi -dmenu -p dunst";
          browser = "xdg-open";
        };
        shortcuts = {
          close = "mod4+c";
          close_all = "mod4+mod1+c";
          history = "mod4+shift+c";
          context = "mod4+n";
        };
        urgency_normal = {
          background = "#222222";
          foreground = "#ffffff";
        };
      };
    };
  };

  nixpkgs.config.allowUnfree = true;
}
