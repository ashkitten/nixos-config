{ pkgs, ... }:

{
  services = {
    nextcloud = {
      enable = true;
      nginx.enable = true;
      hostName = "cloud.kity.wtf";
      maxUploadSize = "50G";
      https = true;
      config = {
        adminpassFile = "/root/nextcloud-secrets/adminpass";
      };
    };

    elasticsearch = {
      enable = true;
      plugins = with pkgs.elasticsearchPlugins; [ ingest-attachment ];
    };
  };

  systemd.services = {
    "nextcloud-aria2" =
      let
        sessionFile = "/var/lib/nextcloud/aria2.session";
      in
        {
          description = "aria2 service for nextcloud";

          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          preStart = ''
            if [[ ! -e "${sessionFile}" ]]
            then
              touch "${sessionFile}"
            fi
          '';
          script = "${pkgs.aria2}/bin/aria2c --enable-rpc --save-session=${sessionFile}";
          reload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

          serviceConfig = {
            User = "nextcloud";
            Group = "nginx";
            Restart = "on-abort";
          };
        };

    "nextcloud-fulltext-elasticsearch-worker" = {
      description = "Elasticsearch Worker for Nextcloud Fulltext Search";

      after = [ "network.target" "elasticsearch.service" ];
      wantedBy = [ "multi-user.target" ];

      script = "/run/current-system/sw/bin/nextcloud-occ fulltextsearch:live -q";
      preStop = "/run/current-system/sw/bin/nextcloud-occ fulltextsearch:stop";

      serviceConfig = {
        Nice = "19";
        Restart = "always";
      };
    };
  };

  services.nginx.virtualHosts."cloud.kity.wtf" = {
    forceSSL = true;
    useACMEHost = "kity.wtf";
  };

  security.acme.certs."kity.wtf".extraDomains."cloud.kity.wtf" = null;
}
