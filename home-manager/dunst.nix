{ pkgs, ... }:

{
  services.dunst = {
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
      urgency_normal = {
        background = "#222222";
        foreground = "#ffffff";
      };
    };
  };

  wayland.windowManager.sway.config.keybindings = {
    "Mod4+c" = "exec dunstctl close-all";
    "Mod4+Shift+c" = "exec dunstctl history-pop";
    "Mod4+Mod1+c" = "exec dunstctl context";
  };

  home.packages = [ pkgs.dunst ];
}
