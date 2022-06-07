{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  
  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-uuid/ec80919e-c34c-4261-bcd5-651c598260e6";

  fileSystems."/" = { device = "/dev/disk/by-uuid/e5caa4eb-c9fd-4212-90ab-a99987c208d1"; fsType = "xfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/B9A8-6EC2"; fsType = "vfat"; };

  swapDevices = [ ];
}
