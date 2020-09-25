{ pkgs, ... }:

{
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud19;
      hostName = "cloud.kity.wtf";
      maxUploadSize = "50G";
      https = true;
      config = {
        adminpassFile = "/root/nextcloud-secrets/adminpass";
      };
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
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "cloud.kity.wtf" ];
}
