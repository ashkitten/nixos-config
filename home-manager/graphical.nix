pkgs: _:

{
  imports = [ (import ./default.nix pkgs) ];

  programs.browserpass.enable = true;

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          follow = "keyboard";
          geometry = "800x5-20+20";
          shrink = "yes";
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = "#d70a53";
          font = "Source Code Pro 10";
          markup = "no";
          format = "<b>%s</b> <i>(%a)</i> <b>%p</b>\\n%b";
          word_wrap = "yes";
          icon_position = "left";
          max_icon_size = 50;
          history_length = 100;
          dmenu = "rofi -dmenu -p dunst";
          browser = "xdg-open";
        };
        shortcuts = {
          close = "mod4+c";
          close_all = "mod4+mod1+c";
          history = "mod4+shift+c";
          context = "mod4+n";
        };
        urgency_normal = {
          background = "#222222";
          foreground = "#ffffff";
        };
      };
    };
  };

  systemd.user.services = {
    "roccat-tools" =
      let
        roccat-tools = pkgs.callPackage ./packages/roccat-tools {};
      in {
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          Environment = [
            "DISPLAY=:0"
            "PATH=${pkgs.xdotool}/bin:${pkgs.xorg.xprop}/bin"
          ];
          ExecStart = "${roccat-tools}/bin/roccat-tools run ${./files/windowmonitor.lua}";
        };
      };
  };
}
