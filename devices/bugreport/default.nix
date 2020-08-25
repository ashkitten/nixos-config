{ config, pkgs, ... }:

{
  imports = [
    ../../desktop.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "bugreport";
    hostId = "87299acd";

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.5"; prefixLength = 24; } ];
  };

  environment.variables.MOZ_USE_XINPUT2 = "1";

  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  hardware.sensor.iio.enable = true;

  system.stateVersion = "20.09";
}
