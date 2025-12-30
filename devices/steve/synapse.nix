{ config, lib, pkgs, ... }:

{
  imports = [
    ./coturn.nix
    ./draupnir.nix
  ];

services.matrix-synapse = {
    enable = true;

    plugins = with config.services.matrix-synapse.package.plugins; [
      synapse-http-antispam
    ];

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

      modules = [
        {
          module = "synapse_http_antispam.HTTPAntispam";
          config = {
            base_url = "http://localhost:8080/api/1/spam_check";
            authorization = "very secret auth string";
            enabled_callbacks = [
              "user_may_invite"
              "user_may_join_room"
            ];
            fail_open = {
              user_may_invite = true;
              user_may_join_room = true;
            };
          };
        }
      ];
    };
  };

  # services.matrix-sliding-sync = {
  #   enable = true;
  #   createDatabase = true;
  #   environmentFile = toString config.secrets.files.sliding_sync_environment_file.file;
  #   settings = {
  #     SYNCV3_SERVER = "https://matrix.kity.wtf";
  #   };
  # };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "synapse";
      metrics_path = "/_synapse/metrics";
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
        "/" = {
          return = "404";
        };

        "/_matrix" = {
          proxyPass = "http://127.0.0.1:8448";
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

        # from https://github.com/cinnyapp/cinny/blob/dev/docker-nginx.conf
    		rewrite ^/config.json$ /config.json break;
        rewrite ^/manifest.json$ /manifest.json break;

        rewrite ^.*/olm.wasm$ /olm.wasm break;
        rewrite ^/sw.js$ /sw.js break;
        rewrite ^/pdf.worker.min.js$ /pdf.worker.min.js break;

        rewrite ^/public/(.*)$ /public/$1 break;
        rewrite ^/assets/(.*)$ /assets/$1 break;

        rewrite ^(.+)$ /index.html break;
      '';
    };
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "matrix.kity.wtf" "element.kity.wtf" "cinny.kity.wtf" ];
}
