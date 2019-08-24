{ lib, pkgs, ... }:

let
  get-system-generation = pkgs.writeShellScriptBin "get-system-generation" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail

    /var/run/current-system/sw/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system | ${pkgs.gnugrep}/bin/grep current | ${pkgs.gawk}/bin/awk '{print $1}'
  '';

  stop-nixos-rollback = pkgs.writeShellScriptBin "stop-nixos-rollback" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail

    ROLLBACK_FILE=/nix/var/nix/rollback-generation

    CURRENT_GENERATION=$(${get-system-generation}/bin/get-system-generation)

    echo Setting "$ROLLBACK_FILE" to "$CURRENT_GENERATION".
    echo "$CURRENT_GENERATION" > "$ROLLBACK_FILE"
  '';
in
  {
    environment.systemPackages = [
      get-system-generation
      stop-nixos-rollback
    ];

    systemd.services.nixos-rollback = {
      path = [ get-system-generation stop-nixos-rollback ];
      script = ''
        if [ ! -f /nix/var/nix/rollback-generation ]; then
          echo Rollback file "/nix/var/nix/rollback-generation" does not exist.
          stop-nixos-rollback
        fi;

        if [[ $(get-system-generation) > $(cat /nix/var/nix/rollback-generation) ]]; then
          /var/run/current-system/sw/bin/nixos-rebuild switch --rollback
        fi;
      '';
    };

    systemd.timers.nixos-rollback = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnActiveSec = "15 min";
        OnUnitInactiveSec = "15 min";
      };
    };
  }
