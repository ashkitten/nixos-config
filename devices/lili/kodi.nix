{ pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  users.users.kodi.isNormalUser = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.kodi-gbm}/bin/kodi-standalone";
        user = "kodi";
      };
    };
  };
}
