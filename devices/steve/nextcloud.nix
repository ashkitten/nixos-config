{ config, pkgs, ... }:

{
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      hostName = "cloud.kity.wtf";
      maxUploadSize = "50G";
      https = true;
      autoUpdateApps.enable = true;
      caching.redis = true;
      database.createLocally = true;
      fastcgiTimeout = 60 * 10; # 10 minutes

      config = {
        adminpassFile = toString config.secrets.files.nextcloud_adminpass.file;
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbtableprefix = "oc_";
      };

      extraOptions = {
        default_phone_region = "US";
      };

      phpOptions = {
        "opcache.interned_strings_buffer" = "16";
        "opcache.jit" = "1255";
        "opcache.jit_buffer_size" = "128M";
      };
    };

    nginx.virtualHosts."cloud.kity.wtf" = {
      forceSSL = true;
      useACMEHost = "kity.wtf";

      locations."/index.php/apps/uppush".extraConfig = ''
        # for up-nextpush
        fastcgi_connect_timeout 10m;
        fastcgi_send_timeout    10m;
        fastcgi_read_timeout    10m;
        fastcgi_buffering off;
      '';

      locations."=/_matrix/push/v1/notify" = {
        proxyPass = "https://cloud.kity.wtf/index.php/apps/uppush/gateway/matrix";
        extraConfig = ''
          proxy_buffering off;
          proxy_connect_timeout 10m;
          proxy_send_timeout    10m;
          proxy_read_timeout    10m;
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [ nodejs ];

  security.acme.certs."kity.wtf".extraDomainNames = [ "cloud.kity.wtf" ];
}
