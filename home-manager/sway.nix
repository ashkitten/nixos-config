{ lib, pkgs, ... }:

let
  wlroots = pkgs.wlroots.overrideAttrs (oldAttrs: rec {
    version = "b614ded3fcb022c4567bbee932a6df3e83acaff6";
    src = pkgs.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = version;
      sha256 = "0a7rc2sv7c2axghkbql0sy02ynw8kb94spmy8hx22vph7my2gynl";
    };
  });

  sway-unwrapped = (pkgs.sway-unwrapped.override {
    inherit wlroots;
  }).overrideAttrs (oldAttrs: rec {
    version = "fcd524bb0d6f3c6cd4f2ddc180520bc56a89aa4a";
    src = pkgs.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = version;
      sha256 = "0x8dwznzi5km8jyyavvsx91amggkndqx98zb2z4fhmmv8npfa4al";
    };
  });

  package = pkgs.sway.override { inherit sway-unwrapped; };

  mod = "Mod4";
in
  {
    wayland.windowManager.sway = {
      inherit package;

      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        modifier = mod;

        terminal = "kitty";
        menu = "rofi -show drun";

        fonts = [ "Terminus (TTF) 10.5" ];

        keybindings = lib.mkOptionDefault {
          "${mod}+r" = "reload";

          "${mod}+apostrophe" = "layout stacking";
          "${mod}+comma" = "layout tabbed";
          "${mod}+period" = "layout toggle split";

          "${mod}+m" = "split h";
          "${mod}+w" = "split v";

          "${mod}+p" = "mode resize";

          "${mod}+Mod1+l" = "exec --no-startup-id loginctl lock-session";

          "${mod}+i" = "exec --no-startup-id rofinsert";

          "Print" = "exec --no-startup-id screenshot monitor";
          "Shift+Print" = "exec --no-startup-id screenshot window";
          "Ctrl+Print" = "exec --no-startup-id screenshot selection";
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
          {
            command = let
              lockCommand = "'swaylock -f -c 000000'";
            in ''
              swayidle -w \
                lock         ${lockCommand} \
                timeout 300  ${lockCommand} \
                timeout 600  'swaymsg "output * dpms off"' \
                resume       'swaymsg "output * dpms on"' \
                before-sleep ${lockCommand}
            '';
          }
          {
            command = ''
              swaybg -i "$(find ~/.wallpapers/ -type f | shuf -n1)"
            '';
          }
        ];
      };
    };
  }
