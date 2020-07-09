{ config, pkgs, ... }:

{
  imports = [
    ../../desktop.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ "nct6775" ];

    kernelParams = [
      "zfs.zfs_vdev_scheduler=none"
    ];
  };

  networking = {
    hostName = "boson";
    hostId = "f31db09b";

    firewall.enable = false;

    hosts = {
      "127.0.0.1" = [ "boson.kity.wtf" ];
    };

    # nat for containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp4s0";
    };
    networkmanager.unmanaged = [ "interface-name:ve-*" ];

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.2"; prefixLength = 24; } ];
  };

  services.ratbagd.enable = true;

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "boson.kity.wtf" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            root = "/var/lib/stuff";
            tryFiles = "$uri =404";
          };
        };
      };
    };
  };

  # TODO: debug why this is broken
  #power.ups = {
  #  enable = true;
  #  ups = {
  #    tripplite = {
  #      driver = "usbhid-ups";
  #      port = "/dev/ttyS0";
  #    };
  #  };
  #};

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

  home-manager.users.ash.wayland.windowManager.sway = {
    config.output = {
      DP-2 = { pos = "0 0"; mode = "2560x1440@143.912Hz"; };
      DP-3 = { pos = "2560 180"; mode = "1920x1080@75Hz"; };
    };

    extraConfig = ''
      workspace 1 output DP-3
    '';
  };

  system.stateVersion = "19.09";
}
