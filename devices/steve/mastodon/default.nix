{ pkgs, lib, config, ... }:

let
  pkgs-pinned = import (pkgs.fetchFromGitHub {
    owner = "ashkitten";
    repo = "nixpkgs";
    rev = "b46bef8c0e4ccd2c69cf7873afcbdef555df705b";
    sha256 = "1lxqmgr1qw74bvags5441q76b88imv4qxw398gii0qi9wdvx8zvg";
  }) {};

  package = pkgs-pinned.mastodon.override {
    version = import ./version.nix;
    srcOverride = pkgs.callPackage ./source.nix {};
    dependenciesDir = ./.;
  };

  hostAddress = "10.200.0.1";
  localAddress = "10.200.0.2";

  cfg = config.containers.mastodon.config.services.mastodon;

  secret = name: toString config.secrets.files."mastodon_${name}".file;
in
  {
    containers.mastodon = {
      privateNetwork = true;
      inherit hostAddress localAddress;
      autoStart = true;

      # nixus doesn't automatically copy keys to containers
      bindMounts."/var/lib/nixus-secrets" = { hostPath = "/var/lib/nixus-secrets"; };

      # steve's disks are slow, it takes a while to start services on a cold boot,
      # so mastodon consistently times out when starting with default timeout
      timeoutStartSec = "5m";

      config = {
        networking.firewall.allowedTCPPorts = [ cfg.webPort cfg.streamingPort ];

        # for elasticsearch
        nixpkgs.config.allowUnfree = true;

        services = {
          mastodon = {
            enable = true;
            inherit package;

            localDomain = "kity.wtf";

            database.passwordFile = secret "databasePassword";

            smtp = {
              createLocally = false;
              host = "smtp.mailgun.org";
              port = 465;
              user = "notifications@kity.wtf";
              fromAddress = "Mastodon <notifications@kity.wtf>";
              passwordFile = secret "smtpPassword";
            };

            elasticsearch.host = "127.0.0.1";

            otpSecretFile = secret "otpSecret";
            secretKeyBaseFile = secret "secretKeyBase";
            vapidPrivateKeyFile = secret "vapidPrivateKey";
            vapidPublicKeyFile = secret "vapidPublicKey";

            extraConfig = {
              BIND = "0.0.0.0";

              MAX_TOOT_CHARS = "65535";
              MAX_DISPLAY_NAME_CHARS = "69";
              MAX_PROFILE_FIELDS = "32";
              MAX_BIO_CHARS = "65535";
              MAX_SEARCH_RESULTS = "100";
            };
          };

          elasticsearch.enable = true;
        };
      };
    };

    services.nginx.virtualHosts."kity.wtf" = {
      root = "${package}/public/";
      forceSSL = true;
      useACMEHost = "kity.wtf";

      locations."/system/".alias = "/var/lib/containers/mastodon/var/lib/mastodon/public-system/";

      locations."/" = {
        tryFiles = "$uri @proxy";
      };

      locations."@proxy" = {
        proxyPass = "http://${localAddress}:${toString(cfg.webPort)}";
        proxyWebsockets = true;
      };

      locations."/api/v1/streaming/" = {
        proxyPass = "http://${localAddress}:${toString(cfg.streamingPort)}/";
        proxyWebsockets = true;
      };
    };
  }
