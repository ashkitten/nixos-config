{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "137.184.0.1";
    defaultGateway6 = "2604:a880:4:1d0::1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="137.184.12.196"; prefixLength=20; }
{ address="10.48.0.5"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2604:a880:4:1d0::384:d000"; prefixLength=64; }
{ address="fe80::c069:35ff:fef4:ed66"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "137.184.0.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "2604:a880:4:1d0::1"; prefixLength = 128; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="c2:69:35:f4:ed:66", NAME="eth0"
    ATTR{address}=="86:0e:ef:a6:65:5f", NAME="eth1"
  '';
}
