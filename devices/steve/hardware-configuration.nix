{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usbhid" "floppy" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { device = "tank/root"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/4A46-4B37"; fsType = "vfat"; };
  fileSystems."/home" = { device = "tank/home"; fsType = "zfs"; };
  fileSystems."/nix" = { device = "tank/nix"; fsType = "zfs"; };

  fileSystems."/var/lib/docker" = { device = "tank/docker"; fsType = "zfs"; };

  fileSystems."/opt/mastodon" = { device = "tank/mastodon"; fsType = "zfs"; };
  fileSystems."/opt/pleroma" = { device = "tank/pleroma"; fsType = "zfs"; };

  swapDevices = [
    { device = "/dev/disk/by-uuid/2169589d-c25e-4675-9077-9df5ccb490fa"; }
    { device = "/dev/disk/by-uuid/6f2cf73f-65d2-4db0-8608-36cdb33abeba"; }
  ];

  nix.maxJobs = lib.mkDefault 8;
}
