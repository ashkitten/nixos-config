# this is just a proxy that passes push notifications to a NoProvider2Push client on an android device on the vpn
# https://unifiedpush.org/users/distributors/np2p/
#
# to configure a device:
# - install NoProvider2Push
# - set "Your address" to the device's static address on the vpn
# - set "Your proxy" to "https://push.kity.wtf/proxy"

{
  services.nginx.virtualHosts."push.kity.wtf" = {
    forceSSL = true;
    useACMEHost = "kity.wtf";

    locations = {
      "/proxy/10.100.0.4:51515/" = {
        proxyPass = "http://10.100.0.4:51515/";
      };
    };

    extraConfig = ''
      allow 132.226.42.65; # matrix.gateway.unifiedpush.org
      deny all;
      client_max_body_size 50M;
    '';
  };

  security.acme.certs."kity.wtf".extraDomainNames = [ "push.kity.wtf" ];
}
