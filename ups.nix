{ pkgs, ... }:

let
  shutdownCommand = pkgs.writeShellScript "upsmon-shutdown" ''
    ${pkgs.systemd}/bin/systemctl poweroff
  '';

  notifyCommand = pkgs.writeShellScript "upsmon-notify" ''
    ${pkgs.dbus}/bin/dbus-send --system / net.nuetzlich.SystemNotifications.Notify "string:$1"
  '';
in
  {
    power.ups = {
      enable = true;
      ups = {
        ups = {
          driver = "usbhid-ups";
          port = "auto";
          directives = [
            "override.battery.runtime.low = 30"
          ];
        };
      };
    };

    environment.etc = {
      "nut/upsd.conf".source = pkgs.writeText "upsd.conf" "";
      "nut/upsd.users".source = pkgs.writeText "upsd.users" ''
        [upsmon]
          password = pass
          upsmon master
      '';
      "nut/upsmon.conf".source = pkgs.writeText "upsmon.conf" ''
        MONITOR ups@localhost 1 upsmon pass master
        SHUTDOWNCMD "${shutdownCommand}"
        NOTIFYCMD "${notifyCommand}"
        NOTIFYFLAG ONLINE SYSLOG+WALL+EXEC
        NOTIFYFLAG ONBATT SYSLOG+WALL+EXEC
        NOTIFYFLAG FSD SYSLOG+WALL+EXEC
        NOTIFYFLAG REPLBATT SYSLOG+WALL+EXEC
        NOTIFYFLAG NOCOMM SYSLOG+WALL+EXEC
      '';
    };

    systemd.user.services.systembus-notify = {
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      script = "${pkgs.systembus-notify}/bin/systembus-notify -q";
    };
  }
