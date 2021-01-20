{ config, pkgs, ... }:

{
  # bind-mount media dir so it's readable for jellyfin
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems."/media" = {
    fsType = "fuse.bindfs";
    device = "/var/lib/nextcloud/data/kity/files/media";
    options = [ "ro" "force-user=jellyfin" "nofail" ];
  };

  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
  };

  services.nginx.virtualHosts."jelly.kity.wtf" = {
    forceSSL = true;
    useACMEHost = "kity.wtf";

    locations = {
      "/" = {
        proxyPass = "http://localhost:8096";
        proxyWebsockets = true;
      };
    };
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "jelly.kity.wtf" ];
}
