{ pkgs, ... }:

let
  mkZetup = dataset: extraConfig: {
    plan = "1h=>10min,1d=>1h,1w=>1d,1m=>1w,1y=>1m";

    destinations.boson = {
      host = "znapzend@boson";
      dataset = "tank/znapzend/steve/${dataset}";
    };
  } // extraConfig;
in
{
  services.znapzend = {
    enable = true;
    pure = true;
    autoCreation = true;
    features.oracleMode = true;

    zetup = {
      "tank/postgresql" = mkZetup "postgresql" {
        presnap = "${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/psql -c 'CHECKPOINT'";
      };

      "tank/nextcloud" = mkZetup "nextcloud" {};
      "tank/root" = mkZetup "root" {};
      "tank/synapse" = mkZetup "synapse" {};
    };
  };
}
