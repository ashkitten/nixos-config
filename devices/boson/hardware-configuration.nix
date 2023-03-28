{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    initrd.supportedFilesystems = [ ];
    kernelModules = [ "kvm-amd" "zfs" ];
    extraModulePackages = [ ];
    kernelParams = [ "resume=UUID=b68651fb-9d82-43fc-b6e9-020ff5d4981d" "resume_offset=24" ];
  };

  fileSystems = {
    "/" = { device = "/dev/disk/by-uuid/b68651fb-9d82-43fc-b6e9-020ff5d4981d"; fsType = "xfs"; };
    "/boot" = { device = "/dev/disk/by-uuid/D097-E4BD"; fsType = "vfat"; };

    "/home/ash/.local/share/Steam" = { device = "/bind/users/ash/steam"; options = [ "bind" "nofail" ]; };
    "/home/ash/games" = { device = "/bind/users/ash/games"; options = [ "bind" "nofail" ]; };
    "/home/ash/tmp" = { device = "/bind/users/ash/tmp"; options = [ "bind" "nofail" ]; };
    "/home/ash/.cache" = { device = "/bind/users/ash/cache"; options = [ "bind" "nofail" ]; };

    "/home/ash" = { device = "tank/home/ash"; fsType = "zfs"; options = [ "nofail" ]; };
    "/home/ash/Projects" = { device = "tank/home/ash/projects"; fsType = "zfs"; options = [ "nofail" ]; };
    "/home/ash/nextcloud" = { device = "tank/home/ash/nextcloud"; fsType = "zfs"; options = [ "nofail" ]; };
    "/home/ash/steam" = { device = "tank/home/ash/steam"; fsType = "zfs"; options = [ "nofail" ]; };
  };

  swapDevices = [
    { device = "/swapfile"; }
  ];

  nix.settings.max-jobs = 12;
}
