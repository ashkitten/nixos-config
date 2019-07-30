{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    <nixos-hardware/lenovo/thinkpad/t450s>
  ];

  networking = {
    hostName = "fucko";
    hostId = "e008702e";

    wireguard.interfaces.wg0.ips = [ "10.100.0.3/24" ];
  };

  hardware.trackpoint = {
    enable = true;
    sensitivity = 90;
    speed = 70;
  };

  services.xserver = {
    xkbVariant = "dvorak";
    dpi = 110;

    libinput = {
      enable = true;
      clickMethod = "clickfinger";
      tapping = false;
    };
  };
}
