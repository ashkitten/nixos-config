{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  boot = {
    kernelModules = [ "nct6775" ];

    kernelParams = [
      "nospectre_v1"
      "nospectre_v2"
      "nospec_store_bypass_disable"
      "zfs.zfs_vdev_scheduler=none"
    ];

    kernelPackages = pkgs.linuxPackages_5_4;
  };

  networking = {
    hostName = "boson";
    hostId = "f31db09b";

    firewall.enable = false;

    # nat for containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp4s0";
    };
    networkmanager.unmanaged = [ "interface-name:ve-*" ];

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
        Option "metamodes" "DP-4: 1920x1080_60 +0+0, DP-2: 1920x1080_60 +1920+0"
      '';
    };

    ratbagd.enable = true;
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
    docker = {
      enable = true;
      storageDriver = "zfs";
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

    users.znapzend = {
      isSystemUser = true;
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANROgXWkBhhJc4VjmbyIabhpQEb/zzqqcOXJQgt7qIY"
      ];
    };

    users.ash.extraGroups = [ "libvirtd" "vboxusers" "docker" ];
  };

  nixpkgs.overlays = [
    (self: super: {
      blender = super.blender.override { cudaSupport = true; };
    })
  ];
}
