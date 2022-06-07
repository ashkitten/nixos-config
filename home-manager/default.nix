{ pkgs, ... }:

{
  imports = [
    ./dunst.nix
    ./i3.nix
    ./kakoune
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
      package = pkgs.rofi-wayland;
      theme = "android_notification";
    };

    obs-studio = {
      enable = true;
      package = pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-vkcapture
        ];
      };
    };

    beets = {
      enable = true;
      package = pkgs.beets.override {
        pluginOverrides = {
          fetchart.enable = true;
          lastfm.enable = true;
          replaygain.enable = true;
          acoustid.enable = true;
        };
      };
      settings = {
        directory = "~/nextcloud/media/music/library";
        library = "~/nextcloud/media/music/library.db";
        plugins = "fetchart replaygain lastgenre chroma";
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
  };

  home.file = {
    ".mozilla/native-messaging-hosts/radical.native.json".text = builtins.toJSON {
      name = "radical.native";
      description = "Radical Native";
      path = "${pkgs.callPackage ../packages/radical-native { rustPlatform = pkgs.rustPackages.rustPlatform; }}/bin/radical-native";
      type = "stdio";
      allowed_extensions = [ "@radical-native" "@riot-webext" ];
    };

    ".local/share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json".source = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json";
  };
}
