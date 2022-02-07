{
  services.nitter = {
    enable = true;
    server = {
      hostname = "nitter.kity.wtf";
      address = "127.0.0.1";
      https = true;
    };
    config.tokenCount = 1;
  };

  services.nginx.virtualHosts."nitter.kity.wtf" = {
    forceSSL = true;
    useACMEHost = "kity.wtf";

    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
    };
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "nitter.kity.wtf" ];
}
