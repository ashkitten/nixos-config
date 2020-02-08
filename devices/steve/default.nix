# TODO: generify with other devices

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./its.nix
    ./nextcloud.nix
    ./znapzend.nix
    ../../auto-rollback.nix
  ];

  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0,9600n8" ];

    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "vm.overcommit_memory" = 1;
      "vm.max_map_count" = 262144;
    };

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

    firewall = {
      allowedTCPPorts = [ 80 443 655 ];
      allowedUDPPorts = [ 655 ];
      trustedInterfaces = [ "tinc.t0" ];

      extraCommands = ''
        # kiwifarms ip range
        iptables -A INPUT -s 103.114.191.0/24 -j DROP
      '';
    };

    defaultGateway6 = { address = "2607:5300:60:3bff:ff:ff:ff:ff"; interface = "enp1s0"; };
    interfaces.enp1s0.ipv6.addresses = [ { address = "2607:5300:60:3b7e::1"; prefixLength = 64; } ];
    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.1"; prefixLength = 24; } ];
  };

  time.timeZone = "America/Los_Angeles";

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
    openssh.enable = true;

    zfs = {
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
      };
      autoScrub.enable = true;
    };

    grafana = {
      enable = true;
      port = 6000;
    };

    prometheus = {
      enable = true;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "zfs" ];
        };
      };

      scrapeConfigs = [
        {
          job_name = "node-exporter";
          static_configs = [
            { targets = [ "127.0.0.1:9100" "10.100.0.2:9100" "10.100.0.3:9100" ]; }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            { targets = [ "127.0.0.1:9090" ]; }
          ];
        }
      ];
    };

    nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "kity.wtf" = {
          forceSSL = true;
          useACMEHost = "kity.wtf";

          extraConfig = ''
            error_page 500 501 502 503 504 /500.html;
            client_max_body_size 80m;
          '';

          locations = {
            "/" = {
              root = "/opt/mastodon/public";
              tryFiles = "$uri @proxy";
            };

            "@proxy" = {
              proxyPass = "http://127.0.0.1:3000";
            };

            "/sw.js" = {
              tryFiles = "$uri @proxy";
              extraConfig = ''
                add_header Cache-Control "public, max-age=0";
              '';
            };

            "~ ^/(emoji|packs|system/accounts/avatars|system/media_attachments/files)" = {
              tryFiles = "$uri @proxy";
              extraConfig = ''
                add_header Cache-Control "public, max-age=31536000, immutable";
              '';
            };

            "/api/v1/streaming" = {
              proxyPass = "http://127.0.0.1:4000";
              proxyWebsockets = true;
            };

            "~ /api/v[12]/search" = {
              tryFiles = "$uri @proxy";
              extraConfig = ''
                access_log off;
              '';
            };

            "= /about".extraConfig = ''
              return 301 https://$host/@kity;
            '';

            "/weechat" = {
              proxyPass = "http://127.0.0.1:5230";
              proxyWebsockets = true;
            };
          };
        };

        "grafana.kity.wtf" = {
          forceSSL = true;
          useACMEHost = "kity.wtf";

          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:6000";
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

    tinc.networks.t0 = {
      hosts = {
        steve = ''
          Address = 192.99.10.126
          Ed25519PublicKey = Ra66u8aLrlVnoO5ZPKzngIzPOsYLILOGJWy49Bje1fI
          Subnet = 10.100.0.1/32
        '';
        boson = ''
          Ed25519PublicKey = X4MR570GYD3rff4cMv8x/2OTDZrcCrobf8chG890WuK
          Subnet = 10.100.0.2/32
        '';
        fucko = ''
          Ed25519PublicKey = 6EneoCfLtLJ1nBG+oLtYsDQcmYNNkuHLS3fY3IZVxFJ
          Subnet = 10.100.0.3/32
        '';
        electron = ''
          Ed25519PublicKey = YvrM+BgYWG3g5YN/oe2D+yZDzM19roOAYceYAz+mJNA
          Subnet = 10.100.0.4/32
        '';
      };
    };
  };

  systemd.services = {
    # restart in one step so the connection doesn't drop
    "tinc.t0".stopIfChanged = false;

    "network-link-tinc.t0".wantedBy = [ "sys-subsystem-net-devices-tinc.t0.device" ];
    "network-addresses-tinc.t0".wantedBy = [ "sys-subsystem-net-devices-tinc.t0.device" ];
  };

  programs.zsh = {
    enable = true;
    promptInit = "
      ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
    ";
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  security.acme.certs = {
    "kity.wtf" = {
      webroot = "/var/lib/acme/acme-challenge";
      email = "example@thisismyactual.email";
      extraDomains = {
        "grafana.kity.wtf" = null;
        "stuff.kity.wtf" = null;
      };
      group = "nginx";
      allowKeysForGroup = true;
    };
  };

  users.users.kity = {
    isNormalUser = true;
    createHome = false;
    uid = 1000;
    extraGroups = [ "wheel" "docker" "systemd-journal" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/nix/var/nix/profiles/per-user/root/channels/nixos-config/devices/${config.networking.hostName}"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  system.stateVersion = "19.09";
}
