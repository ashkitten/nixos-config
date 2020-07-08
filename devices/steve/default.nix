{ config, pkgs, ... }:

{
  imports = [
    ./grafana.nix
    ./hardware-configuration.nix
    ./its.nix
    ./mastodon
    ./mopidy.nix
    ./nextcloud.nix
    ./synapse.nix
    ./syncplay.nix
    ./znapzend.nix
  ];

  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0,9600n8" ];

    loader.grub = {
      enable = true;
      device = "/dev/sda";
      extraConfig = ''
        serial --unit=0 --speed=9600
        terminal_input serial
        terminal_output serial
      '';
    };
  };

  networking = {
    hostName = "steve";
    hostId = "bf2fecf0";

    # nat for containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp1s0";
    };

    firewall.allowedTCPPorts = [ 80 443 ];

    defaultGateway6 = { address = "2607:5300:60:3bff:ff:ff:ff:ff"; interface = "enp1s0"; };
    interfaces.enp1s0.ipv6.addresses = [ { address = "2607:5300:60:3b7e::1"; prefixLength = 64; } ];
    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.1"; prefixLength = 24; } ];
  };

  environment.systemPackages = with pkgs; [
    dialog
    docker-compose
    git
    gptfdisk
    htop
    jq
    lsof
    neovim
    ripgrep
    tmux
    weechat
  ];

  services = {
    openssh.passwordAuthentication = false;

    postgresql.enable = true;

    nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      enableReload = true;

      virtualHosts = {
        "glowing-bear" = {
          default = true;
          listen = [ { addr = "10.100.0.1"; port = 80; } ];

          locations = {
            "/" = {
              root = pkgs.fetchFromGitHub {
                owner = "glowing-bear";
                repo = "glowing-bear";
                rev = "c803bfb3889d537980ed801eeef983edcf91fde1";
                sha256 = "14a3fqsmi28g7j3lzk4l4m47p2iml1aaf3514wazn2clw48lnqhw";
              };

              tryFiles = "$uri $uri/index.html =404";
            };
          };
        };

        "stuff.kity.wtf" = {
          forceSSL = true;
          useACMEHost = "kity.wtf";

          locations = {
            "/" = {
              root = "/var/lib/stuff";
              tryFiles = "$uri =404";
            };
          };
        };
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  security.acme = {
    certs = {
      "kity.wtf" = {
        webroot = "/var/lib/acme/acme-challenge";
        extraDomains = {
          "stuff.kity.wtf" = null;
        };
        group = "nginx";
        allowKeysForGroup = true;
      };
    };
  };

  users.users.kity = {
    isNormalUser = true;
    createHome = false;
    uid = 1000;
    extraGroups = [ "wheel" "docker" "systemd-journal" ];
  };

  nix.gc.automatic = true;

  system.stateVersion = "19.09";
}
