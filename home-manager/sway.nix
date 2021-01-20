{ lib, pkgs, ... }:

let
  mod = "Mod4";

  movementKeys = m: a: {
    "${m}+k" = "${a} up";
    "${m}+j" = "${a} down";
    "${m}+h" = "${a} left";
    "${m}+l" = "${a} right";
  };

  numberKeys = m: a: {
    "${m}+1" = "${a} 1";
    "${m}+2" = "${a} 2";
    "${m}+3" = "${a} 3";
    "${m}+4" = "${a} 4";
    "${m}+5" = "${a} 5";
    "${m}+6" = "${a} 6";
    "${m}+7" = "${a} 7";
    "${m}+8" = "${a} 8";
    "${m}+9" = "${a} 9";
    "${m}+0" = "${a} 10";
  };
in
  {
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      systemdIntegration = false;
      config = {
        modifier = mod;

        terminal = "kitty";
        menu = "rofi -show drun";

        fonts = [ "Terminus (TTF) 10.5" ];

        keybindings = {
          "${mod}+r" = "reload";

          "${mod}+apostrophe" = "layout stacking";
          "${mod}+comma" = "layout tabbed";
          "${mod}+period" = "layout toggle split";

          "${mod}+m" = "split h";
          "${mod}+w" = "split v";

          "${mod}+a" = "focus parent";
          "${mod}+Shift+a" = "focus child";

          "${mod}+space" = "focus mode_toggle";
          "${mod}+Shift+space" = "floating toggle";

          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "sticky toggle";

          "${mod}+Shift+q" = "kill";

          "${mod}+Mod1+l" = "exec loginctl lock-session";

          "${mod}+Return" = "exec kitty";
          "${mod}+d" = "exec rofi -show drun";
          "${mod}+i" = "exec rofinsert";

          "Print" = "exec screenshot monitor";
          "Shift+Print" = "exec screenshot window";
          "Ctrl+Print" = "exec screenshot selection";

          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +2%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -2%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

          "XF86MonBrightnessUp" =  "exec light -A 2";
          "XF86MonBrightnessDown" = "exec light -U 2";

          "${mod}+F12" = "mode passthrough";
        }

        // movementKeys "${mod}" "focus"
        // movementKeys "${mod}+Shift" "move"

        // numberKeys "${mod}" "workspace number"
        // numberKeys "${mod}+Shift" "move container to workspace number";

        modes = {
          passthrough = {
            "${mod}+F12" = "mode default";
          };
        };

        gaps.smartBorders = "on";

        colors = {
          focused =         { background = "#d70a53"; border = "#d70a53"; indicator = "#9909d7"; text = "#ffffff"; childBorder = "#d70a53"; };
          focusedInactive = { background = "#333333"; border = "#333333"; indicator = "#333333"; text = "#888888"; childBorder = "#333333"; };
          unfocused =       { background = "#333333"; border = "#333333"; indicator = "#333333"; text = "#888888"; childBorder = "#333333"; };
          urgent =          { background = "#eb709b"; border = "#eb709b"; indicator = "#eb709b"; text = "#ffffff"; childBorder = "#eb709b"; };
        };

        bars = [
          {
            statusCommand = "${pkgs.python3}/bin/python3 ${./swaybar.py}";
            trayOutput = "*";

            fonts = [ "Terminus (TTF) 10.5" ];

            colors = {
              separator =  "#666666";
              background = "#222222";
              statusline = "#666666";
              focusedWorkspace =  { background = "#d70a53"; border = "#d70a53"; text = "#ffffff"; };
              activeWorkspace =   { background = "#333333"; border = "#333333"; text = "#888888"; };
              inactiveWorkspace = { background = "#333333"; border = "#333333"; text = "#888888"; };
              urgentWorkspace =   { background = "#eb709b"; border = "#eb709b"; text = "#ffffff"; };
            };

            extraConfig = ''
              separator_symbol "  "
            '';
          }
        ];

        startup = [
          # set wallpaper
          { command = ''swaybg -i "$(find ~/.wallpapers/ -type f | shuf -n1)"''; }

          # don't do this stuff in a nested sway
          {
            command = toString (pkgs.writeShellScript "sway-toplevel-startup" ''
              if ! swaymsg -t get_outputs | jq -e 'any(.[].name; . == "WL-1")'; then
                systemctl --user import-environment

                swayidle \
                  lock         'lock' \
                  before-sleep 'lock' &

                # start nextcloud sync client
                nextcloud --background &
              fi
            '');
          }
        ];

        window.commands = [
          # steam non-main windows
          { criteria = { class = "^Steam$"; title = "^(?!Steam$)"; }; command = "floating enable"; }
          # blender user preferences
          { criteria = { class = "^Blender$"; title = "^Blender Preferences$"; }; command = "floating enable"; }
          # open-in-browser extension
          { criteria = { app_id = "^firefox$"; title = "^Extension: \\(Open in Browser\\)"; }; command = "floating enable"; }
          # firefox picture-in-picture
          { criteria = { app_id = "^firefox$"; title = "^Picture-in-Picture$"; }; command = "floating enable"; }
          # nextcloud desktop popup should be floating next to the cursor
          # this affects the regular window too but i don't know how i could differentiate them
          { criteria = { app_id = "^com.nextcloud.desktopclient.nextcloud$"; }; command = "floating enable; move position cursor"; }
        ];
      };

      extraConfig = ''
        titlebar_padding 3 1
      '';

      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND="1";
        export MOZ_USE_XINPUT2="1";
        export XDG_SESSION_TYPE="wayland";
        export XDG_CURRENT_DESKTOP="sway";
      '';
    };

    xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
      [screencast]
      output=
      chooser_cmd="${pkgs.slurp}/bin/slurp -f %o -o"
      chooser_type=simple
    '';

    home.packages = [
      (pkgs.makeDesktopItem {
        name = "sway";
        desktopName = "Sway (nested)";
        exec = "dbus-run-session sway";
      })
    ];
  }
