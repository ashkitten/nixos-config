{ pkgs, ... }:

{
  services = {
    grafana = {
      enable = true;
      port = 6000;
    };

    prometheus = {
      enable = true;

      scrapeConfigs = [
        {
          job_name = "node-exporter";
          static_configs = [
            { targets = [ "127.0.0.1:9100" "10.100.0.2:9100" "10.100.0.3:9100" ]; }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            { targets = [ "127.0.0.1:9090" ]; }
          ];
        }
      ];
    };

    nginx.virtualHosts."grafana.kity.wtf" = {
      forceSSL = true;
      useACMEHost = "kity.wtf";

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:6000";
        };
      };
    };
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "grafana.kity.wtf" ];
}
