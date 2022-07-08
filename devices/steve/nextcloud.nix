{ config, pkgs, ... }:

{
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      hostName = "cloud.kity.wtf";
      maxUploadSize = "50G";
      https = true;
      autoUpdateApps.enable = true;
      config = {
        adminpassFile = toString config.secrets.files.nextcloud_adminpass.file;
      };
      caching.redis = true;
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
  };

  services.nginx.virtualHosts."cloud.kity.wtf" = {
    forceSSL = true;
    useACMEHost = "kity.wtf";

    locations."/index.php/apps/uppush".extraConfig = ''
      # for up-nextpush
      fastcgi_connect_timeout 10m;
      fastcgi_send_timeout    10m;
      fastcgi_read_timeout    10m;
      fastcgi_buffering off;
    '';

    locations."=/_matrix/push/v1/notify".proxyPass = "https://cloud.kity.wtf/index.php/apps/uppush/gateway/matrix";
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "cloud.kity.wtf" ];
}
