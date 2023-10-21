{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    environment = {
      LS_COLORS = "1";
    };

    font = {
      package = pkgs.fira-mono;
      name = "Fira Mono";
      size = 10.5;
    };

    settings = {
      editor = "hx";

      # repaint delay in ms (fps)
      repaint_delay = 1 / 120;
      sync_to_monitor = true;

      enable_audio_bell = false;
      visual_bell_duration = "0.0";
      window_alert_on_bell = true;
      bell_on_tab = true;

      foreground = "#abb2bf";
      background = "#111111";
      background_opacity = "0.8";

      # black
      color0 = "#48483e";
      color8 = "#76715e";

      # red
      color1 = "#dc2566";
      color9 = "#fa2772";

      # green
      color2 = "#8fc029";
      color10 = "#a7e22e";

      # yellow
      color3 = "#d4c96e";
      color11 = "#e7db75";

      # blue
      color4 = "#55bcce";
      color12 = "#66d9ee";

      # magenta
      color5 = "#9358fe";
      color13 = "#ae82ff";

      # cyan
      color6 = "#56b7a5";
      color14 = "#66efd5";

      # white
      color7 = "#acada1";
      color15 = "#cfd0c2";

      kitty_mod = "ctrl+shift";
    };

    keybindings = {
      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      "kitty_mod+s" = "paste_from_selection";
      "shift+insert" = "paste_from_selection";
      "kitty_mod+o" = "pass_selection_to_program";

      "kitty_mod+up"        = "scroll_line_up";
      "kitty_mod+k"         = "scroll_line_up";
      "kitty_mod+down"      = "scroll_line_down";
      "kitty_mod+j"         = "scroll_line_down";
      "kitty_mod+page_up"   = "scroll_page_up";
      "kitty_mod+page_down" = "scroll_page_down";
      "kitty_mod+home"      = "scroll_home";
      "kitty_mod+end"       = "scroll_end";
      "kitty_mod+enter"     = "show_scrollback";

      "kitty_mod+e" = "kitten hints";
      "kitty_mod+p>f" = "kitten hints --type path --program -";
      "kitty_mod+p>shift+f" = "kitten hints --type path";
      "kitty_mod+p>l" = "kitten hints --type line --program -";
      "kitty_mod+p>w" = "kitten hints --type word --program -";
      "kitty_mod+p>h" = "kitten hints --type hash --program -";

      "kitty_mod+u" = "kitten unicode_input";
      "kitty_mod+escape" = "kitty_shell window";
      "kitty_mod+delete" = "clear_terminal reset active";
    };
  };
}
