{ config, ... }:

{
  imports = [
    ../../external/secrets/cotyledon
    ./email.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  networking = {
    hostName = "cotyledon";

    firewall.allowedTCPPorts = [ 80 443 ];

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.5"; prefixLength = 24; } ];
  };

  services = {
    nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "humandomestication.guide" = {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
          };
        };

        "discord.humandomestication.guide" = {
          forceSSL = true;
          enableACME = true;

          locations."/".extraConfig = ''
            return 301 https://discord.gg/WgssQ6SR4q;
          '';
        };
      };
    };

    wiki-js = {
      enable = true;
      settings = {
        db = {
          type = "postgres";
          host = "/run/postgresql";
          user = "wikijs";
        };
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "wiki" ];
      ensureUsers = [
        {
          name = "wikijs";
          ensurePermissions = {
            "DATABASE wiki" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };

  systemd.services.wiki-js.serviceConfig.User = "wikijs";

  nix.gc.automatic = true;

  system.stateVersion = "21.11";
}
