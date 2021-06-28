{ pkgs, ... }:

{
  services.matrix-conduit = {
    enable = true;
    iHaveReadTheFederationWarning = true;
    nginx.enable = true;
    settings = {
      global = {
        server_name = "conduit.kity.wtf";
        allow_encryption = true;
        allow_federation = true;
      };
    };
  };

  services.nginx.virtualHosts."conduit.kity.wtf" = {
    enableACME = false;
    useACMEHost = "kity.wtf";
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "conduit.kity.wtf" ];
}
