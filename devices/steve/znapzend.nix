{ lib, pkgs, ... }:

let
  mkZetup = dataset: extraConfig: {
    plan = "1h=>10min,1d=>1h,1w=>1d";

    destinations.boson = {
      host = "znapzend@boson";
      dataset = "tank/znapzend/steve/${dataset}";
      plan = "1h=>10min,1d=>1h,1w=>1d,1m=>1w,1y=>1m";
    };
  } // extraConfig;
in
{
  services.zfs.autoSnapshot.enable = lib.mkForce false;

  services.znapzend = {
    enable = true;
    pure = true;
    autoCreation = true;
    features = {
      oracleMode = true;
      skipIntermediates = true;
      compressed = true;
    };

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
