{ pkgs, ... }:

{
  imports = [
    # ./dunst.nix
    ./firefox.nix
    ./kitty.nix
    ./neovim
    ./packages.nix
    ./sway.nix
    ./zsh
  ];

  # # make sure user has the same config and overlays as system
  # xdg.configFile."nixpkgs/config.nix".text = ''(import <nixpkgs/nixos> {}).config.nixpkgs.config'';
  # xdg.configFile."nixpkgs/overlays.nix".text = ''(import <nixpkgs/nixos> {}).config.nixpkgs.overlays'';

  # gtk = {
  #   enable = true;
  #   theme = {
  #     package = pkgs.arc-theme;
  #     name = "Arc-Dark";
  #   };
  #   iconTheme = {
  #     package = pkgs.numix-icon-theme;
  #     name = "Numix";
  #   };
  # };

  programs = {
    browserpass.enable = true;

    git = {
      enable = true;
      userName = "ash lea";
      userEmail = "example@thisismyactual.email";
      aliases = {
        l = "log --abbrev-commit --pretty=oneline -n 10";
        cp-branch = ''
          branch "cherry-pick-$1" "$2"
          cherry-pick $1
        '';
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
      package = pkgs.rofi-wayland;
      theme = "android_notification";
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vkcapture
        obs-livesplit-one
      ];
    };

    beets = {
      enable = true;
      package = pkgs.beets.override {
        pluginOverrides = {
          fetchart.enable = true;
          lastfm.enable = true;
          replaygain.enable = true;
          acoustid.enable = true;
          lyrics.enable = true;
        };
      };
      settings = {
        directory = "~/nextcloud/media/music/library";
        library = "~/nextcloud/media/music/library.db";
        plugins = "fetchart replaygain lastgenre chroma edit scrub acousticbrainz mbsync lyrics";
        lastgenre = {
          canonical = true;
          fallback = "";
          prefer_specific = true;
        };
      };
    };

    mpv = {
      enable = true;
      config = {
        ytdl-raw-options = "write-auto-sub=,write-sub=,sub-lang=en";
        sub-auto = "fuzzy";
        sid = 1;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  
    gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };

    # nushell = {
    #   enable = true;
    #   package = pkgs.nushellFull;
    # };

    # starship = {
    #   enable = true;
    # };
  };
  
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };

  home = {
    sessionVariables = {
      VISUAL = "hx";
      EDITOR = "hx";
      PAGER = "less";
    };

    file = {
      ".mozilla/native-messaging-hosts/radical.native.json".text = builtins.toJSON {
        name = "radical.native";
        description = "Radical Native";
        path = "${pkgs.callPackage ../packages/radical-native { rustPlatform = pkgs.rustPackages.rustPlatform; }}/bin/radical-native";
        type = "stdio";
        allowed_extensions = [ "@radical-native" "@riot-webext" ];
      };

      ".local/share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json".source = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json";
    };
  };
}
