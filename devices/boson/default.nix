{ config, pkgs, ... }:

{
  imports = [
    ../../desktop.nix
    ../../ups.nix
    ../../sdr.nix
    ./hardware-configuration.nix
  ];


  boot = {
    kernelModules = [ "nct6775" ];

    kernelParams = [
      "zfs.zfs_vdev_scheduler=none"
      "amd_pstate=passive"
    ];
    
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  networking = {
    hostName = "boson";
    hostId = "f31db09b";

    # nat for containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp5s0";
    };
    networkmanager.unmanaged = [ "interface-name:ve-*" ];

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.2"; prefixLength = 24; } ];

    firewall.interfaces."enp5s0".allowedUDPPorts = [ 7100 ];
    firewall.interfaces."enp5s0".allowedTCPPorts = [ 7100 ];
  };

  services.ratbagd.enable = true;

  services.icecream = {
    scheduler = {
      enable = true;
      openFirewall = true;
    };

    daemon = {
      enable = true;
      openFirewall = true;
      openBroadcast = true;
      nice = 19;
      extraArgs = [ "-vvv" ];
      user = "icecream";
    };
  };

  systemd.services.iceccd-daemon.serviceConfig = {
    CPUSchedulingPolicy = "idle";
    IOSchedulingClass = "idle";
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    # monado
  ];

  virtualisation = {
    libvirtd.enable = true;
  #   spiceUSBRedirection.enable = true;
  #   virtualbox.host = {
  #     enable = true;
  #     enableExtensionPack = true;
  #   };
  #   vmware.host = {
  #     enable = true;
  #     extraConfig = ''
  #       mks.gl.allowUnsupportedDrivers = "TRUE"
  #       mks.vk.allowUnsupportedDevices = "TRUE"
  #     '';
  #   };
  };

  users = {
    groups.nut.gid = 84;
    groups.znapzend = {};
    groups.icecream = {};

    users.nut = {
      isSystemUser = true;
      uid = 84;
      home = "/var/lib/nut";
      group = "nut";
    };

    users.icecream = {
      isSystemUser = true;
      group = "icecream";
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
      DP-2 = { mode = "5120x1440@119.970Hz"; adaptive_sync = "on"; };
    };

    extraConfig = ''
      workspace 1 output DP-1
    '';
  };
  
  nixpkgs.overlays = [
    # (import ../../external/nixpkgs-wayland/overlay.nix)
  ];

  system.stateVersion = "19.09";
  home-manager.users.ash.home.stateVersion = "22.05";
}
