{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" "zfs" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { device = "zfsroot"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/5215-A7F2"; fsType = "vfat"; };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
