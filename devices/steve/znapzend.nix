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

    zetup = {
      "tank/mastodon" = mkZetup "mastodon" {
        presnap = "${pkgs.nixos-container}/bin/nixos-container run mastodon -- sudo -u postgres psql -U postgres -c 'CHECKPOINT'";
      };

      "tank/nextcloud" = mkZetup "nextcloud" {};
      "tank/root" = mkZetup "root" {};
    };
  };
}
