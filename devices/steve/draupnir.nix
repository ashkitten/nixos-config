# adapted from https://cgit.rory.gay/Rory-Open-Architecture.git/tree/host/Rory-ovh/services/matrix/draupnir.nix
{ config, lib, ... }:

{
  services.draupnir = {
    enable = true;
    homeserverUrl = "https://matrix.kity.wtf";
    accessTokenFile = toString config.secrets.files.draupnir_access_token.file;

    settings = {
      rawHomeserverUrl = "https://matrix.kity.wtf";

      managementRoom = "#draupnir-management:kity.wtf";
      recordIgnoredInvites = true; # Let's log ignored invites, just incase
      autojoinOnlyIfManager = true; # Let's not open ourselves up to DoS attacks
      automaticallyRedactForReasons = [ "*" ]; # I always want autoredact
      #roomStateBackingStore.enabled = true; # broken under nix.

      backgroundDelayMS = 10; # delay isn't needed, I don't mind the performance hit
      pollReports = false;

      admin.enableMakeRoomAdminCommand = true;
      commands.ban.defaultReasons = [];
      protections = {
        wordlist = {
          words = [];
          minutesBeforeTrusting = 0;
        };
      };

      web = {
        enabled = true;
        address = "127.0.0.1";
        port = 8080;
        abuseReporting = {
          enabled = true;
        };
        synapseHTTPAntispam = {
          enabled = true;
          authorization = "very secret auth string";
        };
      };
    };
  };

  services.nginx.virtualHosts."matrix.kity.wtf".locations = {
    # https://github.com/the-draupnir-project/Draupnir/blob/main/test/nginx.conf
    "~ ^/_matrix/client/(r0|v3)/rooms/([^/\\s]*)/report/(.*)$".extraConfig = ''
      mirror /report_mirror;

      # Abuse reports should be sent to Draupnir.
      # The r0 endpoint is deprecated but still used by many clients.
      # As of this writing, the v3 endpoint is the up-to-date version.

      # Alias the regexps, to ensure that they're not rewritten.
      set $room_id $2;
      set $event_id $3;
      proxy_pass http://127.0.0.1:8080/api/1/report/$room_id/$event_id;
    '';

    "/report_mirror".extraConfig = ''
      internal;
      proxy_pass http://127.0.0.1:8448$request_uri;
    '';
  };

  # remove once CI checks pass on https://github.com/NixOS/nixpkgs/pull/400194
  documentation.nixos.enable = lib.mkForce false;
}
