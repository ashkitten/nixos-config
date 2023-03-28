{ pkgs, ... }:

{
  services = {
    dbus.enable = false;
    dbus-broker.enable = true;
  };

  environment.systemPackages = [
    pkgs.dbus
  ];
}
