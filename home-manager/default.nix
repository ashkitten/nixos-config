{ pkgs, ... }:

{
  imports = [
    ./dunst.nix
    ./i3.nix
    ./neovim
    ./packages.nix
    ./sway.nix
    ./zsh
  ];

  # make sure user has the same config and overlays as system
  xdg.configFile."nixpkgs/config.nix".text = ''(import <nixpkgs/nixos> {}).config.nixpkgs.config'';
  xdg.configFile."nixpkgs/overlays.nix".text = ''(import <nixpkgs/nixos> {}).config.nixpkgs.overlays'';

  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Dark";
    };
    iconTheme = {
      package = pkgs.numix-icon-theme;
      name = "Numix";
    };
  };

  programs = {
    browserpass.enable = true;

    git = {
      enable = true;
      userName = "ash lea";
      userEmail = "example@thisismyactual.email";
      aliases = {
        l = "log --abbrev-commit --pretty=oneline -n 10";
      };
      extraConfig = {
        transfer.fsckobjects = true;
        core = {
          excludesfile = "~/.gitignore";
          autocrlf = "input";
        };
        push.default = "simple";
      };
    };

    tmux = {
      enable = true;
      extraConfig = builtins.readFile ./dotfiles/.tmux.conf;
    };

    rofi = {
      enable = true;
      theme = "android_notification";
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
    };

    beets = {
      enable = true;
      package = pkgs.beets.override {
        enableFetchart = true;
        # lastgenre plugin
        enableLastfm = true;
        enableReplaygain = true;
      };
      settings = {
        directory = "~/nextcloud/media/music/library";
        library = "~/nextcloud/media/music/library.db";
        plugins = "fetchart replaygain lastgenre";
      };
    };

    mpv = {
      enable = true;
      config = {
        ytdl-raw-options = "write-auto-sub=,sub-lang=en";
        sid = 1;
      };
    };

    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };
  };

  home.file = {
    ".mozilla/native-messaging-hosts/radical.native.json".text = builtins.toJSON {
      name = "radical.native";
      description = "Radical Native";
      path = "${pkgs.callPackage ../packages/radical-native {}}/bin/radical-native";
      type = "stdio";
      allowed_extensions = [ "@radical-native" "@riot-webext" ];
    };
  };

  systemd.user = {
    startServices = true;

    services = {
      "gmrender-resurrect" = {
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = "${pkgs.gmrender-resurrect}/bin/gmediarender -f %H --gstout-videosink fakesink";
        };
      };
    };
  };
}
