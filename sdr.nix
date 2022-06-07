{ pkgs, ... }:

{
  home-manager.users.ash.home.packages = with pkgs; [ gqrx ];
  users.users.ash.extraGroups = [ "plugdev" ];
  hardware.hackrf.enable = true;
  hardware.rtl-sdr.enable = true;
}
