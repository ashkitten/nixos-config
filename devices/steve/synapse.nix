{ pkgs, ... }:

{
  services.matrix-synapse = {
    enable = true;
    server_name = "kity.wtf";

    enable_metrics = true;
    url_preview_enabled = true;

    listeners = [
      {
        bind_address = "localhost";
        port = 8448;
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [
          { compress = false; names = [ "client" "federation" ]; }
        ];
      }
      {
        bind_address = "localhost";
        port = 9000;
        type = "metrics";
        tls = false;
        resources = [];
      }
    ];
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
              "m.identity_server" =  { "base_url" = "https://vector.im"; };
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
          proxyPass = "http://localhost:8448";
        };
      };
    };
  };

  security.acme.certs."kity.wtf".extraDomains."matrix.kity.wtf" = null;
}
