{ pkgs, ... }:

{
  imports = [
    ../../external/nixos-hardware/raspberry-pi/4

    ./kodi
  ];

  networking = {
    hostName = "lili";
    hostId = "b9b485ea16";
  };

  hardware = {
    sound.enable = true;

    raspberry-pi."4" = {
      fkms-3d.enable = true;
      apply-overlays-dtmerge.enable = true;
      audio.enable = true;
      dwc2.enable = true;
    };
  };
}
