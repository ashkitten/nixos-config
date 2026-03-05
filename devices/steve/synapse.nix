{ config, lib, pkgs, ... }:

{
  imports = [
    ./coturn.nix
    ./draupnir.nix
  ];

services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    configureRedisLocally = true; # needed for workers

    plugins = with config.services.matrix-synapse.package.plugins; [
      synapse-http-antispam
    ];

    workers = {
      "federation_sender" = {
        worker_listeners = [
          {
            bind_addresses = [ "127.0.0.1" ];
            port = 9001;
            type = "metrics";
            tls = false;
            resources = [];
          }
          {
            bind_addresses = [ "127.0.0.1" ];
            path = "/run/matrix-synapse/federation_sender_replication.sock";
            type = "http";
            resources = [
              { names = [ "replication" ]; }
            ];
          }
        ];
      };

      "federation_receiver" = {
        worker_listeners = [
          {
            bind_addresses = [ "127.0.0.1" ];
            port = 8084;
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              { names = [ "federation" ]; }
            ];
          }
          {
            bind_addresses = [ "127.0.0.1" ];
            port = 9002;
            type = "metrics";
            tls = false;
            resources = [];
          }
        ];
      };

      "client" = {
        worker_listeners = [
          {
            bind_addresses = [ "127.0.0.1" ];
            path = "/run/matrix-synapse/client_replication.sock";
            type = "http";
            resources = [
              { names = [ "replication" ]; }
            ];
          }
          {
            bind_addresses = [ "127.0.0.1" "10.100.0.1" ];
            port = 8085;
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              { names = [ "client" ]; }
            ];
          }
          {
            bind_addresses = [ "127.0.0.1" ];
            port = 9003;
            type = "metrics";
            tls = false;
            resources = [];
          }
        ];
      };

      # "media" = {
      #   worker_app = "synapse.app.media_repository";
      #   worker_listeners = [
      #     {
      #       bind_addresses = [ "127.0.0.1" ];
      #       port = 8083;
      #       type = "http";
      #       tls = false;
      #       x_forwarded = true;
      #       resources = [
      #         { names = [ "media" ]; }
      #       ];
      #     }
      #     {
      #       bind_addresses = [ "127.0.0.1" ];
      #       port = 9004;
      #       type = "metrics";
      #       tls = false;
      #       resources = [];
      #     }
      #   ];
      # };
    };

    settings = {
      server_name = "kity.wtf";

      enable_metrics = true;
      url_preview_enabled = true;
      max_upload_size = "100M";
      enable_registration = true;
      registration_requires_token = true;

      # enable_media_repo = false;

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
          path = "/run/matrix-synapse/main_replication.sock";
          type = "http";
          resources = [
            { names = [ "replication" ]; }
          ];
        }
        {
          bind_addresses = [ "127.0.0.1" "10.100.0.1" ];
          port = 8448;
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            { names = [ "federation" "client" ]; }
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

      instance_map = {
        main.path = "/run/matrix-synapse/main_replication.sock";
        client.path = "/run/matrix-synapse/client_replication.sock";
        federation_sender.path = "/run/matrix-synapse/federation_sender_replication.sock";
      };

      federation_sender_instances = [
        "federation_sender"
      ];

      # stream_writers = {
      #   events = [ "client" ];
      #   typing = [ "client" ];
      #   to_device = [ "client" ];
      #   account_data = [ "client" ];
      #   receipts = [ "client" ];
      #   presence = [ "client" ];
      #   device_lists = [ "client" ];
      # };

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

  services.synapse-auto-compressor.enable = true;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "synapse";
      metrics_path = "/_synapse/metrics";
      static_configs = [
        {
          targets = [ "127.0.0.1:9000" ];
          labels = {
            instance = "kity.wtf";
            job = "master";
            index = "1";
          };
        }
        {
          targets = [ "127.0.0.1:9001" ];
          labels = {
            instance = "kity.wtf";
            job = "federation_sender";
            index = "1";
          };
        }
        {
          targets = [ "127.0.0.1:9002" ];
          labels = {
            instance = "kity.wtf";
            job = "federation_receiver";
            index = "1";
          };
        }
        {
          targets = [ "127.0.0.1:9003" ];
          labels = {
            instance = "kity.wtf";
            job = "client";
            index = "1";
          };
        }
        # {
        #   targets = [ "127.0.0.1:9004" ];
        #   labels = {
        #     instance = "kity.wtf";
        #     job = "media";
        #     index = "1";
        #   };
        # }
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

        # "/_matrix/(media|(client|federation)/v1/media)" = {
        #   proxyPass = "http://127.0.0.1:8083";
        # };

        "/_matrix/federation/v\d/(version|event|state|state_ids|backfill|get_missing_events|publicRooms|query|make_join|make_leave|send_join|send_leave|make_knock|send_knock|invite|event_auth|timestamp_to_event|exchange_third_party_invite|user/devices|hierarchy)" = {
          proxyPass = "http://127.0.0.1:8084";
        };

        "/_matrix/client/((r0|v3)/sync|(api/v1|r0|v3)/events|(api/v1|r0|v3)/initialSync|(api/v1|r0|v3)/rooms/[/]+/initialSync)" = {
          proxyPass = "http://127.0.0.1:8085";
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
