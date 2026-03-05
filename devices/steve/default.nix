{ config, pkgs, ... }:

{
  imports = [
    ../../external/secrets/steve
    ./email.nix
    ./grafana.nix
    ./hardware-configuration.nix
    ./jellyfin.nix
    ./nextcloud.nix
    ./synapse.nix
    ./znapzend.nix
  ];

  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0,9600n8" ];

    loader.grub = {
      enable = true;
      device = "/dev/disk/by-id/wwn-0x5000cca24bc13fbb";
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

  services = {
    openssh.settings.PasswordAuthentication = false;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableJIT = true;
      settings = {
        max_connections = 200; # default is 100
        shared_buffers = "8GB"; # like a quarter of ram
        effective_cache_size = "16GB"; # half of ram
        work_mem = "16MB"; # default is 4MB
        autovacuum = true;
      };
    };

    nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      clientMaxBodySize = "100m";

      appendConfig = ''
        worker_processes auto;
      '';

      eventsConfig = ''
        worker_connections 1024;
      '';

      virtualHosts = {
        # need this for /.well-known
        "kity.wtf" = {
          forceSSL = true;
          useACMEHost = "kity.wtf";

          locations = {
            "/" = {
              root = "/var/www/kity.wtf";
              tryFiles = "$uri =404";
            };
          };
        };
      };
    };
  };

  security.acme = {
    certs = {
      "kity.wtf" = {
        webroot = "/var/lib/acme/acme-challenge";
        extraDomainNames = [
          "mail.kity.wtf"
        ];
        group = "nginx";
      };
    };
  };

  nix.gc.automatic = true;

  system.stateVersion = "19.09";
}
