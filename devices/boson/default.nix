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
          url = "https://patchwork.kernel.org/patch/11043277/mbox/";
          sha256 = "16b74z3wa8aq8f637daw8nj74d9sx5flapja94xj22n4ig7zmsbl";
        };
      })
      ({
        name = "k10temp ryzen 3xxx";
        patch = pkgs.fetchpatch {
          url = "https://patchwork.kernel.org/patch/11043271/mbox/";
          sha256 = "02gsyv14hff3i7v77dhhhgi6x2xyl0dg3jn80j4aynb4dz3aqjcm";
        };
      })
    ];
  };

  networking = {
    hostName = "boson";
    hostId = "f31db09b";

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.2"; prefixLength = 24; } ];
  };

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

  virtualisation.libvirtd.enable = true;

  users = {
    groups.nut.gid = 84;

    users.nut = {
      isSystemUser = true;
      uid = 84;
      home = "/var/lib/nut";
      group = "nut";
    };

    users.ash.extraGroups = [ "libvirtd" ];
  };

  nixpkgs.overlays = [
    (self: super: {
      blender = super.blender.override { cudaSupport = true; };
    })
  ];
}
