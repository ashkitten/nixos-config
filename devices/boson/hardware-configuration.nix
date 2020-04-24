{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-amd" "zfs" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = { device = "tank/root"; fsType = "zfs"; };
    "/home" = { device = "tank/home"; fsType = "zfs"; };
    "/home/ash" = { device = "tank/home/ash"; fsType = "zfs"; };
    "/home/ash/tmp" = { device = "tank/home/ash/tmp"; fsType = "zfs"; };
    "/home/ash/Projects" = { device = "tank/home/ash/projects"; fsType = "zfs"; };
    "/home/ash/nextcloud" = { device = "tank/home/ash/nextcloud"; fsType = "zfs"; };
    "/home/ash/.local/share/Steam" = { device = "tank/home/ash/steam"; fsType = "zfs"; };

    "/boot" = { device = "/dev/disk/by-uuid/FAC7-B487"; fsType = "vfat"; };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/585d6c99-7fb9-418f-b5e9-9c4c3151b904"; }
  ];

  nix.maxJobs = 12;
}
