{ pkgs, ... }:

{
  imports = [
    ./dunst.nix
    ./packages.nix
    ./sway.nix
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

    neovim = {
      enable = true;
      withPython = true;
      withPython3 = true;
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
      plugins = [ pkgs.obs-wlrobs ];
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
