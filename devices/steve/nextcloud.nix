{ config, pkgs, ... }:

{
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      hostName = "cloud.kity.wtf";
      maxUploadSize = "50G";
      https = true;
      autoUpdateApps.enable = true;
      database.createLocally = true;
      fastcgiTimeout = 60 * 10; # 10 minutes
      configureRedis = true;

      config = {
        adminpassFile = toString config.secrets.files.nextcloud_adminpass.file;
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
      };

      settings = {
        dbtableprefix = "oc_";
        default_phone_region = "US";
        log_type = "file";
        overwriteprotocol = "https";
        "memories.exiftool" = "${pkgs.exiftool}/bin/exiftool";
        # "memories.vod.ffmpeg" = "${pkgs.ffmpeg}/bin/ffmpeg";
        # "memories.vod.ffprobe" = "${pkgs.ffmpeg}/bin/ffprobe";
      };

      phpOptions = {
        "opcache.enable_cli" = "1";
        "opcache.jit" = "1255";
        "opcache.jit_buffer_size" = "128M";
        "opcache.interned_strings_buffer" = "16";
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
          proxy_connect_timeout 10m;
          proxy_send_timeout    10m;
          proxy_read_timeout    10m;
          proxy_buffering off;
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [ nodejs ];

  security.acme.certs."kity.wtf".extraDomainNames = [ "cloud.kity.wtf" ];
}
