{ pkgs, ... }:

{
  services = {
    dbus = {
      enable = false;
      implementation = "broker";
    };
    dbus-broker.enable = true;
  };

  environment.systemPackages = [
    pkgs.dbus
  ];
}
