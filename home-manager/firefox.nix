{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
        plasma5Packages.plasma-browser-integration
      ];
    };
  };
}
