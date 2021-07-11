{ lib, pkgs, ... }:

{
  services.nginx.virtualHosts."rocks.kity.wtf" = {
    root = pkgs.element-web.override {
      conf = {
        default_server_config."m.homeserver" = {
          "base_url" = "https://rocks.kity.wtf";
          "server_name" = "rocks.kity.wtf";
        };
        showLabsSettings = true;
      };
    };
    locations = {
      "= /.well-known/matrix/server".extraConfig = let
        server = { "m.server" = "rocks.kity.wtf:443"; };
      in ''
        add_header Content-Type application/json;
        return 200 '${builtins.toJSON server}';
      '';
      "/_matrix" = {
        proxyPass = "http://172.16.0.118:8000";
      };
      "/_matrix/media" = {
        proxyPass = "http://localhost:8000";
      };
    };
  };

  systemd.services."matrix-media-repo" = let
    config = builtins.toFile "config.yaml" (builtins.toJSON {
      repo = {
        bindAddress = "127.0.0.1";
        port = 8000;
        logDirectory = "-";
      };
      database.postgres = "postgres://matrix-media-repo@/matrix-media-repo?host=/var/run/postgresql";
      homeservers = [
        { name = "rocks.kity.wtf"; csApi = "http://rocks.kity.wtf"; }
      ];
      admins = [ "@kity:rocks.kity.wtf" ];
      datastores = [
        {
          type = "file";
          enabled = true;
          forKinds = [ "all" ];
          opts = {
            path = "/var/lib/matrix-media-repo";
          };
        }
      ];
    });
  in {
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.matrix-media-repo}/bin/media_repo --config ${config}
    '';
    serviceConfig = {
      User = "matrix-media-repo";
    };
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "matrix-media-repo";
        ensurePermissions = {
          "DATABASE \"matrix-media-repo\"" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [
      "matrix-media-repo"
    ];
  };

  users.users."matrix-media-repo" = {
    isSystemUser = true;
    home = "/var/lib/matrix-media-repo";
    createHome = true;
  };
}
