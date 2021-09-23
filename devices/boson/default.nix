{ config, pkgs, ... }:

{
  imports = [
    ./conduit.nix
    ../../desktop.nix
    ./hardware-configuration.nix
    ../../ups.nix
  ];

  boot = {
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
      "127.0.0.1" = [ "home.kity.wtf" ];
    };

    # nat for containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp3s0f0";
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
      "home.kity.wtf" = {
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

    appendConfig = ''
      rtmp {
        server {
          listen 1935;
          chunk_size 4096;

          allow publish 127.0.0.1;
          deny publish all;

          application kity {
            live on;
            record off;
          }
        }
      }
    '';
  };

  environment.systemPackages = with pkgs; [
    virtmanager
  ];

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    # disable for now (linux 5.10 unsupported)
    #virtualbox.host = {
    #  enable = true;
    #  enableExtensionPack = true;
    #};
  };

  users = {
    groups.nut.gid = 84;
    groups.znapzend = {};

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
      group = "znapzend";
    };

    users.ash.extraGroups = [ "libvirtd" "vboxusers" ];
  };

  home-manager.users.ash.wayland.windowManager.sway = {
    config.output = {
      DP-2 = { pos = "0 0"; mode = "5120x1440@119.970Hz"; };
    };

    extraConfig = ''
      workspace 1 output DP-2
      output DP-1 disable
    '';
  };

  system.stateVersion = "19.09";
}
