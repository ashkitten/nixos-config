{ pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./kitty.nix
    ./packages.nix
    ./zsh
  ];

  # # make sure user has the same config and overlays as system
  # xdg.configFile."nixpkgs/config.nix".text = ''(import <nixpkgs/nixos> {}).config.nixpkgs.config'';
  # xdg.configFile."nixpkgs/overlays.nix".text = ''(import <nixpkgs/nixos> {}).config.nixpkgs.overlays'';

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
      package = pkgs.python3.pkgs.beets.override {
        pluginOverrides = {
          fetchart.enable = true;
          lastfm.enable = true;
          replaygain.enable = true;
          lyrics.enable = true;
          beetcamp = { enable = true; propagatedBuildInputs = [ pkgs.python3.pkgs.beetcamp ]; };
        };
      };
      settings = {
        directory = "~/nextcloud/media/music/library";
        library = "~/nextcloud/media/music/library.db";
        plugins = "fetchart replaygain lastgenre chroma edit scrub mbsync lyrics bandcamp";
        lastgenre = {
          canonical = true;
          fallback = "";
          prefer_specific = true;
        };
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
  };
  
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
      indicator = true;
    };
  };

  home = {
    sessionVariables = {
      VISUAL = "hx";
      EDITOR = "hx";
      PAGER = "less";
    };
  };
}
