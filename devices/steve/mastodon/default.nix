{ pkgs, lib, config, ... }:

let
  package = pkgs.mastodon.override {
    version = import ./version.nix;
    srcOverride = pkgs.callPackage ./source.nix {};
    dependenciesDir = ./.;
  };

  hostAddress = "10.200.0.1";
  localAddress = "10.200.0.2";

  cfg = config.containers.mastodon.config.services.mastodon;
in
  {
    containers.mastodon = {
      privateNetwork = true;
      inherit hostAddress localAddress;
      autoStart = true;

      config = {
        networking.firewall.allowedTCPPorts = [ cfg.webPort cfg.streamingPort ];

        # for elasticsearch
        nixpkgs.config.allowUnfree = true;

        services = {
          mastodon = {
            enable = true;
            inherit package;

            localDomain = "kity.wtf";

            smtp = {
              createLocally = false;
              host = "smtp.mailgun.org";
              port = 465;
              user = "notifications@kity.wtf";
              fromAddress = "Mastodon <notifications@kity.wtf>";
            };

            elasticsearch.host = "127.0.0.1";

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
