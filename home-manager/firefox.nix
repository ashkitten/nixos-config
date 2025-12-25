{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
        kdePackages.plasma-browser-integration
      ];
    };
  };
}
