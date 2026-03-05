{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 655 ];
    allowedUDPPorts = [ 655 ];
    trustedInterfaces = [ "tinc.t0" ];
  };

  services.tinc.networks.t0 = {
    # package = pkgs.tinc_pre.overrideAttrs (old: {
    #   buildInputs = old.buildInputs ++ [
    #     pkgs.miniupnpc
    #   ];
    #   configureFlags = old.configureFlags ++ [
    #     "--enable-miniupnpc"
    #   ];
    # });

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
      claire = ''
        Ed25519PublicKey = dHGLpxfciozvbOzt5tM4dbGLYJ8q85Oz3JkZ2p5gI9J
        Subnet = 10.100.0.7/32
      '';
    };
  };
}
