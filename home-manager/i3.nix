{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      inherit (config.wayland.windowManager.sway.config) modifier terminal menu fonts keybindings modes gaps colors bars;
    };
  };
}
