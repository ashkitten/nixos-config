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

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.3"; prefixLength = 24; } ];
  };

  services.xserver = {
    xkbVariant = "dvorak";
    dpi = 110;

    inputClassSections = [
      ''
        Identifier "Trackpoint Settings"
        MatchProduct "AlpsPS/2 ALPS DualPoint Stick"
        Driver "libinput"
        Option "AccelSpeed" "-0.3"
      ''
    ];

    libinput = {
      enable = true;
      clickMethod = "clickfinger";
      tapping = false;
    };
  };

  # sdr stuff
  services.udev.packages = with pkgs; [ rtl-sdr ];
  home-manager.users.ash.home.packages = with pkgs; [ gqrx ];
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];
}
