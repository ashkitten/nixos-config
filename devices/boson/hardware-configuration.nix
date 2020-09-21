{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    initrd.supportedFilesystems = [ ];
    kernelModules = [ "kvm-amd" "zfs" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = { device = "/dev/disk/by-uuid/12ce6f08-182b-47de-95df-8bf73565d1c6"; fsType = "f2fs"; options = [ "compress_algorithm=zstd" ]; };
    "/boot" = { device = "/dev/disk/by-uuid/D097-E4BD"; fsType = "vfat"; };

    "/home/ash/.local/share/Steam" = { device = "/bind/users/ash/steam"; options = [ "bind" ]; };
    "/home/ash/games" = { device = "/bind/users/ash/games"; options = [ "bind" ]; };
    "/home/ash/tmp" = { device = "/bind/users/ash/tmp"; options = [ "bind" ]; };
    "/home/ash/.cache" = { device = "/bind/users/ash/cache"; options = [ "bind" ]; };

    "/home/ash" = { device = "tank/home/ash"; fsType = "zfs"; };
    "/home/ash/Projects" = { device = "tank/home/ash/projects"; fsType = "zfs"; };
    "/home/ash/nextcloud" = { device = "tank/home/ash/nextcloud"; fsType = "zfs"; };
  };

  swapDevices = [
    { device = "/swapfile"; }
  ];

  nix.maxJobs = 12;
}
