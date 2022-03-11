# derived from https://nixos.wiki/wiki/Matrix#Coturn_with_Synapse
{ config, lib, ... }:

{
  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = toString config.secrets.files.coturn_static_auth_secret.file;
    realm = "turn.kity.wtf";
    cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
    extraConfig = ''
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  networking.firewall = {
    interfaces.enp1s0 = let
      range = with config.services.coturn; [
        { from = min-port; to = max-port; }
      ];

      ports = with config.services.coturn; [
        listening-port
        tls-listening-port
      ];
    in {
      allowedUDPPortRanges = range;
      allowedUDPPorts = ports;
      allowedTCPPortRanges = range;
      allowedTCPPorts = ports;
    };
  };

  security.acme.certs.${config.services.coturn.realm} = {
    webroot = "/var/lib/acme/acme-challenge";
    # this annoyingly soft-requires a zerossl cert because of chromium's webrtc library
    # https://matrix-org.github.io/synapse/latest/turn-howto.html
    server = "https://acme.zerossl.com/v2/DV90";
    extraLegoFlags = [
      "--eab"
      "--kid=${lib.fileContents ../../external/secrets/steve/secrets/zerossl_eab_kid}"
      "--hmac=${lib.fileContents ../../external/secrets/steve/secrets/zerossl_eab_hmac}"
    ];
    postRun = "systemctl restart coturn.service";
    group = "turnserver";
  };

  services.matrix-synapse.settings = with config.services.coturn; {
    # not sure if it's okay to add stun uris to the turn_uris but it seems to work
    # according to the webrtc spec a client MAY use a turn candidate as a stun server but at least firefox does not seem to do this
    # also, firefox doesn't seem to support stuns: uris even though element-android does, so i'm just gonna have both here ¯\_(ツ)_/¯
    turn_uris = [
      "stun:${realm}:${toString listening-port}"
      "stuns:${realm}:${toString tls-listening-port}"
      "turns:${realm}:${toString tls-listening-port}?transport=udp"
      "turns:${realm}:${toString tls-listening-port}?transport=tcp"
    ];
    # FIXME: should use extraConfigFiles to include this without putting it in the nix store
    turn_shared_secret = lib.fileContents ../../external/secrets/steve/secrets/coturn_static_auth_secret;
    turn_user_lifetime = "1h";
  };
}
