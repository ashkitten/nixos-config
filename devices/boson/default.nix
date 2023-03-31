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
      externalInterface = "enp3s0f0";
    };
    networkmanager.unmanaged = [ "interface-name:ve-*" ];

    interfaces."tinc.t0".ipv4.addresses = [ { address = "10.100.0.2"; prefixLength = 24; } ];
  };

  services.ratbagd.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    # monado
  ];

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
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
