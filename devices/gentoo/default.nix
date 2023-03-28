{ config, lib, pkgs, ... }:

{
  imports = [
    ../../desktop.nix
    ./hardware-configuration.nix
    ../../external/Jovian-NixOS/modules
  ];

  #boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_jovian;

  networking = {
    hostName = "gentoo";
    hostId = "9e023b2a";

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.6"; prefixLength = 24; } ];
  };
  
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandlePowerKeyLongPress=suspend
  '';
  
  services.xserver.desktopManager.plasma5.enable = true;
  hardware.pulseaudio.enable = false;
  # xdg.portal.extraPortals = with pkgs; lib.mkForce [
  #   xdg-desktop-portal-gtk
  #   xdg-desktop-portal-wlr
  # ];

  home-manager.users.ash.wayland.windowManager.sway = {
    config = {
      output = {
        eDP-1 = { transform = "90"; };
      };
    
      input = {
        "10248:4117:FTS3528:00_2808:1015" = { map_to_output = "eDP-1"; };
      };
    };
  };
  
  jovian = {
    steam.enable = true;
  };
  
  system.stateVersion = "22.05";
  home-manager.users.ash.home.stateVersion = "22.05";
}
