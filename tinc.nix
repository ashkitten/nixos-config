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
      fucko = ''
        Ed25519PublicKey = 6EneoCfLtLJ1nBG+oLtYsDQcmYNNkuHLS3fY3IZVxFJ
        Subnet = 10.100.0.3/32
      '';
      mclargehuge = ''
        Ed25519PublicKey = uPXwJS7rSM0fqdnlnnPd4ZsBA/Vk4P5pjtuP9TgdkmP
        Subnet = 10.100.0.4/32
      '';
      cotyledon = ''
        Ed25519PublicKey = 3sTDFLbHBOg+1Q3H7FwjNFxwJGqwwPvR+4UqLh0y2kN
        Subnet = 10.100.0.5/32
      '';
      gentoo = ''
        Ed25519PublicKey = yiXRRIv3S5tzvueKj5FMy2iBqGTd+gmwdzkGglZdpBE
        Subnet = 10.100.0.6/32
      '';
      claire = ''
        Ed25519PublicKey = dHGLpxfciozvbOzt5tM4dbGLYJ8q85Oz3JkZ2p5gI9J
        Subnet = 10.100.0.7/32
      '';
    };
  };
}
