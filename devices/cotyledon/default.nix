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
          # TODO: fix for https://github.com/NixOS/nixpkgs/blob/2d864d1843c54a11f7f5b0279f937d73b3bd0a39/nixos/modules/services/databases/postgresql.md?plain=1#L49
          # ensurePermissions = {
          #   "DATABASE wiki" = "ALL PRIVILEGES";
          # };
        }
      ];
    };
  };

  systemd.services.wiki-js.serviceConfig.User = "wikijs";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDv9V3siJ54ralGYL0Fw/sZLSfW8YhMvdfHsvXy15fFe+xwWyBnNRTKjVg5I0tIWIfiK/go+qteRV2w6Zi+tlJ+96nggDhiASCXA9MCtYxtXxF4TTbE2o14ss7p2qWrhWM3L0of9BVRV7neNFkmnVnsV7+3H2kk1R7bLyQZzdEKnNrbw4xg7ktgP911j3mp/CmYzkS3Ckf3J2wNWHMoWT/Y1f+owQfS6gXIjJoAW9bX28TeCKQezi0ujfK4SXWrhIQjtkNFqrza5Tk8eOTWd0s7oMqco65MsJ36nIFC918N/Ga6m+DJWmBSI1Pepr3ZWCjQq8Da6Iv1PPvK5/cLSxgEmIz4Mio+BSWF9eKSlBiMWTONnI1uZ4w4zrqW9tI0yjRQlaELlt5Z9QHMRLMGBgli7/H52xRPb6OI/2hpokT/7QzR/MCotEe8GPbYVAWYA/pgl5z3S8FCLQieFax+IAgLH9MVX60ytuVZRvrXRA7jza2ZLZzIbzAgc/AwYLTymnE= anbl@ananas"
  ];

  nix.gc.automatic = true;

  system.stateVersion = "21.11";
}
