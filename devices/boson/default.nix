{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  boot = {
    kernelModules = [ "nct6775" ];

    kernelParams = [ "nospectre_v1" "nospectre_v2" "nospec_store_bypass_disable" ];

    kernelPackages = pkgs.linuxPackages_latest;

    kernelPatches = [
      ({
        name = "ryzen 3xxx device ids";
        patch = pkgs.fetchpatch {
          url = "https://patchwork.kernel.org/patch/11043277/raw/";
          sha256 = "0xjps6sdjk9gjjmzydl443crv707ww2f00jz52znim0lq2ihy2vw";
        };
      })
      ({
        name = "k10temp ryzen 3xxx";
        patch = pkgs.fetchpatch {
          url = "https://patchwork.kernel.org/patch/11043271/raw/";
          sha256 = "062n1j3ccipwc9cxpji74bf538qbr19dglnknk9sl8i0z715ph1m";
        };
      })
    ];
  };

  networking = {
    hostName = "boson";
    hostId = "f31db09b";

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.2"; prefixLength = 24; } ];
  };

  hardware.openrazer.enable = true;

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];

      xrandrHeads = [
        { output = "DP-4"; primary = true; }
        { output = "DP-2"; }
      ];

      screenSection = ''
        Option "Coolbits" "12"
        Option "metamodes" "DP-4: 1920x1080_75 +0+0, DP-2: 1920x1080_75 +1920+0"
      '';
    };
  };

  power.ups = {
    enable = true;
    ups = {
      tripplite = {
        driver = "usbhid-ups";
        port = "/dev/ttyS0";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    virtmanager
  ];

  virtualisation = {
    libvirtd.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  users = {
    groups.nut.gid = 84;

    users.nut = {
      isSystemUser = true;
      uid = 84;
      home = "/var/lib/nut";
      group = "nut";
    };

    users.ash.extraGroups = [ "libvirtd" "vboxusers" "plugdev" ];
  };

  nixpkgs.overlays = [
    (self: super: {
      blender = super.blender.override { cudaSupport = true; };
    })
  ];
}
