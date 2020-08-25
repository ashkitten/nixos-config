{ pkgs, ... }:

{
  users.users.guest = {
    isNormalUser = true;
    createHome = false;
    uid = 2000;
  };

  home-manager.users.guest = { pkgs, ... }: {
    home.packages = with pkgs; [
      firefox
      steam
      wine
      winetricks
    ];
  };
}
