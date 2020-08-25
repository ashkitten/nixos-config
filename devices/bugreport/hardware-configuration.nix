{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { device = "/dev/disk/by-uuid/ab53913a-b7ff-44eb-a5a9-d56f39a53ecf"; fsType = "f2fs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/9B5A-7A4F"; fsType = "vfat"; };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  #hardware.video.hidpi.enable = lib.mkDefault true;
}
