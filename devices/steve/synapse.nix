{ config, lib, pkgs, ... }:

{
  imports = [
    ./coturn.nix
  ];

services.matrix-synapse = {
    enable = true;

    settings = {
      server_name = "kity.wtf";

      enable_metrics = true;
      url_preview_enabled = true;
      max_upload_size = "100M";
      enable_registration = true;
      registration_requires_token = true;
      trusted_key_servers = lib.mkForce [
        {
          server_name = "matrix.org";
          verify_keys = {
            "ed25519:auto" = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
            "ed25519:a_RXGa" = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
          };
        }
        {
          server_name = "nyrina.link";
          verify_keys = {
            "ed25519:oHl6VZ" = "XTek8L9rdvEakMnQQ0q6V/1m66JCjUVO1iqfIGHPf0c";
          };
        }
      ];

      listeners = [
        {
          bind_addresses = [ "127.0.0.1" "10.100.0.1" ];
          port = 8448;
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            { compress = false; names = [ "client" "federation" ]; }
          ];
        }
        {
          bind_addresses = [ "127.0.0.1" ];
          port = 9000;
          type = "metrics";
          tls = false;
          resources = [];
        }
      ];
    };

    sliding-sync = {
      enable = true;
      createDatabase = true;
      environmentFile = toString config.secrets.files.sliding_sync_environment_file.file;
      settings = {
        SYNCV3_SERVER = "https://matrix.kity.wtf";
      };
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "synapse";
      static_configs = [
        { targets = [ "127.0.0.1:9000" ]; }
      ];
    }
  ];

  services.nginx.virtualHosts = {
    "kity.wtf" = {
      locations = {
        "= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "matrix.kity.wtf:443"; };
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';

        "= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" =  { "base_url" = "https://matrix.kity.wtf"; };
              "org.matrix.msc3575.proxy" = { "url" = "https://matrix.kity.wtf"; };
            };
          # ACAO required to allow riot-web on any URL to request this json file
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
      };
    };

    "matrix.kity.wtf" = {
      forceSSL = true;
      useACMEHost = "kity.wtf";

      locations = {
        "/".extraConfig = ''
            return 404;
        '';

        "/_matrix" = {
          proxyPass = "http://127.0.0.1:8448";
        };

        "~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
          proxyPass = "http://${config.services.matrix-synapse.sliding-sync.settings.SYNCV3_BINDADDR}";
        };
      };
    };

    "element.kity.wtf" = {
      forceSSL = true;
      useACMEHost = "kity.wtf";

      root = pkgs.element-web.override {
        conf = {
          default_server_config."m.homeserver" = {
            "base_url" = "https://matrix.kity.wtf";
            "server_name" = "kity.wtf";
          };
          show_labs_settings = true;
        };
      };

      locations."/".extraConfig = ''
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Content-Security-Policy "frame-ancestors 'none'";
      '';
    };

    "cinny.kity.wtf" = {
      forceSSL = true;
      useACMEHost = "kity.wtf";

      root = pkgs.cinny;

      locations."/".extraConfig = ''
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Content-Security-Policy "frame-ancestors 'none'";
      '';
    };
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "matrix.kity.wtf" "element.kity.wtf" "cinny.kity.wtf" ];
}
