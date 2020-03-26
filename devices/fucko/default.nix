{ config, pkgs, ... }:

{
  imports = [
    ../../desktop.nix
    ../../external/nixos-hardware/lenovo/thinkpad/t450s
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "fucko";
    hostId = "e008702e";

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.3"; prefixLength = 24; } ];
  };

  zramSwap.enable = true;

  services.xserver.xkbVariant = "dvorak";
  home-manager.users.ash.wayland.windowManager.sway.config.input = {
    "*" = { xkb_layout = "dvorak"; };
  };

  # sdr stuff
  services.udev.packages = with pkgs; [ rtl-sdr ];
  home-manager.users.ash.home.packages = with pkgs; [ gqrx ];
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  system.stateVersion = "19.09";
}
