{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 655 ];
    allowedUDPPorts = [ 655 ];
    trustedInterfaces = [ "tinc.t0" ];
  };

  services.tinc.networks.t0 = {
    package = pkgs.tinc_pre.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [
        pkgs.miniupnpc
      ];
      configureFlags = old.configureFlags ++ [
        "--enable-miniupnpc"
      ];
    });

    extraConfig = ''
      ConnectTo = steve
      Autoconnect = yes
      LocalDiscovery = yes
      UPnP = yes
    '';

    hosts = {
      steve = ''
        Address = 192.99.10.126
        Ed25519PublicKey = Ra66u8aLrlVnoO5ZPKzngIzPOsYLILOGJWy49Bje1fI
        Subnet = 10.100.0.1/32
      '';
      boson = ''
        Ed25519PublicKey = X4MR570GYD3rff4cMv8x/2OTDZrcCrobf8chG890WuK
        Subnet = 10.100.0.2/32
      '';
      fucko = ''
        Ed25519PublicKey = 6EneoCfLtLJ1nBG+oLtYsDQcmYNNkuHLS3fY3IZVxFJ
        Subnet = 10.100.0.3/32
      '';
      electron = ''
        Ed25519PublicKey = K3pjyj0S2CEmPiCSp/8phTT9JvZ781D6Z3jDDOss3KJ
        Subnet = 10.100.0.4/32
      '';
    };
  };

  systemd.services = {
    # restart in one step so the connection doesn't drop
    "tinc.t0".stopIfChanged = false;

    "network-link-tinc.t0".wantedBy = [ "sys-subsystem-net-devices-tinc.t0.device" ];
    "network-addresses-tinc.t0".wantedBy = [ "sys-subsystem-net-devices-tinc.t0.device" ];
  };
}
