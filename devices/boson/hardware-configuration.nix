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
    "/boot" = { device = "/dev/disk/by-uuid/FAC7-B487"; fsType = "vfat"; };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/585d6c99-7fb9-418f-b5e9-9c4c3151b904"; }
  ];

  nix.maxJobs = 12;
}
